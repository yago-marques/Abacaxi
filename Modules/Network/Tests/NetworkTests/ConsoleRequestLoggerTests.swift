import XCTest
@testable import Network

final class ConsoleRequestLoggerTests: XCTestCase {
    func test_logRequest_prettyPrintsValidJSONBody() throws {
        var lines: [String] = []
        let logger = ConsoleRequestLogger(isEnabled: true, write: { lines.append($0) })
        let url = try XCTUnwrap(URL(string: "https://api.example.com/accounts"))
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = #"{"name":"Ana","age":30}"#.data(using: .utf8)

        logger.logRequest(request)

        let output = lines.joined()
        XCTAssertTrue(output.contains("\"name\" : \"Ana\""), "expected indented/pretty JSON, got: \(output)")
        XCTAssertTrue(output.contains("POST"))
    }

    func test_logResponse_fallsBackToRawStringForNonJSONBody() throws {
        var lines: [String] = []
        let logger = ConsoleRequestLogger(isEnabled: true, write: { lines.append($0) })
        let url = try XCTUnwrap(URL(string: "https://api.example.com/accounts"))
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        let plainTextBody = "not json".data(using: .utf8)

        logger.logResponse(response, data: plainTextBody, error: nil)

        XCTAssertTrue(lines.joined().contains("not json"))
    }

    func test_logResponse_doesNotCrashOnEmptyBody() {
        var lines: [String] = []
        let logger = ConsoleRequestLogger(isEnabled: true, write: { lines.append($0) })

        logger.logResponse(nil, data: Data(), error: nil)

        XCTAssertFalse(lines.isEmpty)
    }

    func test_logging_isSilentWhenDisabled() throws {
        var lines: [String] = []
        let logger = ConsoleRequestLogger(isEnabled: false, write: { lines.append($0) })
        let url = try XCTUnwrap(URL(string: "https://api.example.com/accounts"))
        let request = URLRequest(url: url)

        logger.logRequest(request)
        logger.logResponse(nil, data: nil, error: nil)

        XCTAssertTrue(lines.isEmpty)
    }
}
