import XCTest
@testable import Network

final class ConsoleRequestLoggerTests: XCTestCase {
    func test_logRequest_prettyPrintsValidJSONBody() throws {
        var lines: [String] = []
        let logger = ConsoleRequestLogger(isEnabled: true, write: { lines.append($0) })
        let url = try XCTUnwrap(URL(string: "https://api.example.com/accounts"))
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = Data(#"{"name":"Ana","age":30}"#.utf8)

        logger.logRequest(request)

        let output = lines.joined()
        XCTAssertTrue(output.contains("\"name\" : \"Ana\""), "expected indented/pretty JSON, got: \(output)")
        XCTAssertTrue(output.contains("POST"))
        XCTAssertTrue(output.contains("┌── REQUEST"))
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
        let plainTextBody = Data("not json".utf8)

        logger.logResponse(response, data: plainTextBody, error: nil)

        let output = lines.joined()
        XCTAssertTrue(output.contains("not json"))
        XCTAssertTrue(output.contains("┌── RESPONSE"))
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

    func test_logRequest_redactsSensitiveHeaders() throws {
        var lines: [String] = []
        let logger = ConsoleRequestLogger(isEnabled: true, write: { lines.append($0) })
        let url = try XCTUnwrap(URL(string: "https://api.example.com/attempts"))
        var request = URLRequest(url: url)
        request.setValue("secret", forHTTPHeaderField: "X-API-Key")
        request.setValue("device-id", forHTTPHeaderField: "X-Device-ID")

        logger.logRequest(request)

        let output = lines.joined()
        XCTAssertTrue(output.contains("X-API-Key: <redacted>"))
        XCTAssertTrue(output.contains("X-Device-ID: device-id"))
        XCTAssertFalse(output.contains("secret"))
    }
}
