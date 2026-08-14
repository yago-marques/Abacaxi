import XCTest
@testable import NetworkInterfaces

final class HTTPEndpointTests: XCTestCase {
    private struct MinimalEndpoint: HTTPEndpointProtocol {
        let path: String
    }

    func test_defaults_methodIsGet() {
        let endpoint = MinimalEndpoint(path: "/accounts")

        XCTAssertEqual(endpoint.method, .get)
    }

    func test_defaults_headersAndQueryItemsAreEmpty() {
        let endpoint = MinimalEndpoint(path: "/accounts")

        XCTAssertTrue(endpoint.headers.isEmpty)
        XCTAssertTrue(endpoint.queryItems.isEmpty)
    }

    func test_defaults_bodyAndBaseURLAreNil() {
        let endpoint = MinimalEndpoint(path: "/accounts")

        XCTAssertNil(endpoint.body)
        XCTAssertNil(endpoint.baseURL)
    }

    func test_conformingType_canOverrideEveryDefault() throws {
        struct CreateAccountEndpoint: HTTPEndpointProtocol {
            let path = "/accounts"
            let method: HTTPMethod = .post
            let headers: HTTPHeaders = ["X-Custom": "value"]
            let queryItems: [URLQueryItem] = [URLQueryItem(name: "dryRun", value: "true")]
            let body: Data?
            let baseURL: URL?
        }

        let endpoint = CreateAccountEndpoint(
            body: Data("{}".utf8),
            baseURL: try XCTUnwrap(URL(string: "https://auth.example.com"))
        )

        XCTAssertEqual(endpoint.method, .post)
        XCTAssertEqual(endpoint.headers["X-Custom"], "value")
        XCTAssertEqual(endpoint.queryItems, [URLQueryItem(name: "dryRun", value: "true")])
        XCTAssertEqual(endpoint.body, Data("{}".utf8))
        XCTAssertEqual(endpoint.baseURL, URL(string: "https://auth.example.com"))
    }
}
