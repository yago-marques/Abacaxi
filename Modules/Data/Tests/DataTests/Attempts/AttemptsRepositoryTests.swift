import Foundation
import XCTest
@testable import Data

final class AttemptsRepositoryTests: XCTestCase {
    func test_factory_make_returnsAnAttemptsRepository() {
        let httpClient = HTTPClientStub()
        let sut = AttemptsRepositoryFactory.make(httpClient: httpClient, apiKey: "api-key")

        XCTAssertTrue(sut is AttemptsRepository)
    }

    func test_fetchAttempts_sendsTheAttemptsEndpointWithAuthenticationHeaders() async throws {
        let (sut, doubles) = makeSUTAndDoubles()
        let deviceID = UUID()

        _ = try await sut.fetchAttempts(deviceID: deviceID)

        XCTAssertEqual(doubles.receivedEndpoint?.path, "/v1/attempts")
        XCTAssertEqual(doubles.receivedEndpoint?.headers["X-Device-ID"], deviceID.uuidString)
        XCTAssertEqual(doubles.receivedEndpoint?.headers["X-API-Key"], "api-key")
    }

    func test_fetchAttempts_mapsTheAPIResponse() async throws {
        let (sut, _) = makeSUTAndDoubles()

        let result = try await sut.fetchAttempts(deviceID: UUID())

        XCTAssertEqual(result.remaining, 17)
        XCTAssertEqual(result.limit, 20)
        XCTAssertEqual(result.windowSeconds, 3_600)
    }

    func test_fetchAttempts_propagatesTheTransportError() async {
        let (sut, doubles) = makeSUTAndDoubles()
        let expectedError = NSError(domain: "AttemptsRepositoryTests", code: 1)
        doubles.stubbedError = expectedError

        do {
            _ = try await sut.fetchAttempts(deviceID: UUID())
            XCTFail("Expected an error")
        } catch {
            XCTAssertEqual((error as NSError).domain, expectedError.domain)
            XCTAssertEqual((error as NSError).code, expectedError.code)
        }
    }
}

private extension AttemptsRepositoryTests {
    typealias SUT = AttemptsRepository
    typealias Doubles = HTTPClientStub

    struct Response: Decodable {
        let remaining: Int
        let limit: Int
        let windowSeconds: Int
    }

    func makeSUTAndDoubles() -> (sut: SUT, doubles: Doubles) {
        let httpClient = HTTPClientStub()
        httpClient.stubbedData = """
        { "remaining": 17, "limit": 20, "window_seconds": 3600 }
        """.data(using: .utf8)
        let sut = AttemptsRepository(httpClient: httpClient, apiKey: "api-key")
        return (sut, httpClient)
    }
}
