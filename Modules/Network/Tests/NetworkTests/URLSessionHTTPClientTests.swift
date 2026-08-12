import XCTest
import NetworkInterfaces
@testable import Network

final class URLSessionHTTPClientTests: XCTestCase {
    private struct Account: Codable, Equatable {
        let id: String
        let name: String
    }

    private struct TestEndpoint: HTTPEndpointProtocol {
        let path: String
        var method: HTTPMethod = .get
        var headers: HTTPHeaders = [:]
        var queryItems: [URLQueryItem] = []
        var body: Data?
        var baseURL: URL?
    }

    override func setUp() {
        super.setUp()
        MockURLProtocol.handler = nil
        MockURLProtocol.lastRequest = nil
    }

    override func tearDown() {
        MockURLProtocol.handler = nil
        MockURLProtocol.lastRequest = nil
        super.tearDown()
    }

    private func makeSUT(isLoggingEnabled: Bool = false) throws -> URLSessionHTTPClient {
        let baseURL = try XCTUnwrap(URL(string: "https://api.example.com"))
        let configuration = NetworkConfiguration(baseURL: baseURL, isLoggingEnabled: isLoggingEnabled)
        return URLSessionHTTPClient(configuration: configuration, session: MockURLProtocol.makeSession())
    }

    // MARK: - HTTP methods

    func test_send_defaultEndpoint_usesGET() throws {
        let sut = try makeSUT()
        MockURLProtocol.handler = { _ in .init(statusCode: 200, data: Data("{}".utf8)) }

        let expectation = expectation(description: "completion")
        let endpoint = TestEndpoint(path: "/accounts")
        sut.send(endpoint) { (_: Result<EmptyResponse, NetworkError>) in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(MockURLProtocol.lastRequest?.httpMethod, "GET")
    }

    func test_send_eachHTTPMethod_isSentAsIs() throws {
        let sut = try makeSUT()
        let methods: [HTTPMethod] = [.get, .post, .put, .patch, .delete]
        MockURLProtocol.handler = { _ in .init(statusCode: 200, data: Data("{}".utf8)) }

        for method in methods {
            let expectation = expectation(description: "completion-\(method.rawValue)")
            let endpoint = TestEndpoint(path: "/accounts", method: method)
            sut.send(endpoint) { (_: Result<EmptyResponse, NetworkError>) in
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 1)

            XCTAssertEqual(MockURLProtocol.lastRequest?.httpMethod, method.rawValue)
        }
    }

    func test_send_endpointWithBaseURLOverride_usesEndpointBaseURL() throws {
        let sut = try makeSUT()
        MockURLProtocol.handler = { _ in .init(statusCode: 200, data: Data("{}".utf8)) }
        let overrideBaseURL = try XCTUnwrap(URL(string: "https://auth.example.com"))

        let expectation = expectation(description: "completion")
        let endpoint = TestEndpoint(path: "/token", baseURL: overrideBaseURL)
        sut.send(endpoint) { (_: Result<EmptyResponse, NetworkError>) in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(MockURLProtocol.lastRequest?.url?.host, "auth.example.com")
    }

    // MARK: - Decoding

    func test_send_async_decodesSuccessfulResponse() async throws {
        let sut = try makeSUT()
        let account = Account(id: "1", name: "Ana")
        let encodedAccount = try JSONEncoder().encode(account)
        MockURLProtocol.handler = { _ in .init(statusCode: 200, data: encodedAccount) }

        let result: Account = try await sut.send(TestEndpoint(path: "/accounts/1"))

        XCTAssertEqual(result, account)
    }

    func test_send_completionHandler_decodesSuccessfulResponse() throws {
        let sut = try makeSUT()
        let account = Account(id: "1", name: "Ana")
        let encodedAccount = try JSONEncoder().encode(account)
        MockURLProtocol.handler = { _ in .init(statusCode: 200, data: encodedAccount) }

        let expectation = expectation(description: "completion")
        var received: Account?
        sut.send(TestEndpoint(path: "/accounts/1")) { (result: Result<Account, NetworkError>) in
            received = try? result.get()
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(received, account)
    }

    // MARK: - Error mapping

    func test_send_non2xxStatus_mapsToStatusCodeError() async throws {
        let sut = try makeSUT()
        MockURLProtocol.handler = { _ in .init(statusCode: 404, data: Data("not found".utf8)) }

        do {
            let _: Account = try await sut.send(TestEndpoint(path: "/accounts/missing"))
            XCTFail("expected NetworkError.statusCode")
        } catch let NetworkError.statusCode(code, data) {
            XCTAssertEqual(code, 404)
            XCTAssertEqual(data, Data("not found".utf8))
        } catch {
            XCTFail("expected NetworkError.statusCode, got \(error)")
        }
    }

    func test_send_malformedJSON_mapsToDecodingError() async throws {
        let sut = try makeSUT()
        MockURLProtocol.handler = { _ in .init(statusCode: 200, data: Data("not json".utf8)) }

        do {
            let _: Account = try await sut.send(TestEndpoint(path: "/accounts/1"))
            XCTFail("expected NetworkError.decoding")
        } catch NetworkError.decoding {
            // expected
        } catch {
            XCTFail("expected NetworkError.decoding, got \(error)")
        }
    }

    // MARK: - Parity between call styles

    func test_send_asyncAndCompletionHandler_produceEquivalentResults() async throws {
        let sut = try makeSUT()
        let account = Account(id: "1", name: "Ana")
        let encodedAccount = try JSONEncoder().encode(account)
        MockURLProtocol.handler = { _ in .init(statusCode: 200, data: encodedAccount) }

        let asyncResult: Account = try await sut.send(TestEndpoint(path: "/accounts/1"))

        let expectation = expectation(description: "completion")
        var completionResult: Account?
        sut.send(TestEndpoint(path: "/accounts/1")) { (result: Result<Account, NetworkError>) in
            completionResult = try? result.get()
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 1)

        XCTAssertEqual(asyncResult, completionResult)
    }

    // MARK: - Cancellation

    func test_cancel_completionHandler_completesWithCancelledError() throws {
        let sut = try makeSUT()
        MockURLProtocol.handler = { _ in .init(statusCode: 200, data: Data("{}".utf8), delay: 0.3) }

        let expectation = expectation(description: "completion")
        var received: Result<EmptyResponse, NetworkError>?
        let cancellable = sut.send(TestEndpoint(path: "/accounts")) { result in
            received = result
            expectation.fulfill()
        }
        cancellable.cancel()

        wait(for: [expectation], timeout: 1)

        guard case .failure(.cancelled) = received else {
            XCTFail("expected .failure(.cancelled), got \(String(describing: received))")
            return
        }
    }

    func test_cancel_async_throwsCancelledError() async throws {
        let sut = try makeSUT()
        MockURLProtocol.handler = { _ in .init(statusCode: 200, data: Data("{}".utf8), delay: 0.3) }

        let task = Task { () -> EmptyResponse in
            try await sut.send(TestEndpoint(path: "/accounts"))
        }
        task.cancel()

        let result = await task.result
        XCTAssertThrowsError(try result.get()) { error in
            let isCancellation = error is CancellationError || {
                if case NetworkError.cancelled = error { return true }
                return false
            }()
            XCTAssertTrue(isCancellation, "expected cancellation, got \(error)")
        }
    }
}
