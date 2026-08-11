import XCTest
@testable import NetworkInterfaces

final class HTTPHeadersTests: XCTestCase {
    func test_dictionaryLiteral_buildsHeaders() {
        let headers: HTTPHeaders = ["Accept": "application/json"]

        XCTAssertEqual(headers["Accept"], "application/json")
    }

    func test_merging_keepsKeysUniqueToEachSide() {
        let base: HTTPHeaders = ["X-App-Version": "1.0", "Accept": "application/json"]
        let override: HTTPHeaders = ["X-Correlation-Id": "IOS-123"]

        let merged = base.merging(override)

        XCTAssertEqual(merged["X-App-Version"], "1.0")
        XCTAssertEqual(merged["Accept"], "application/json")
        XCTAssertEqual(merged["X-Correlation-Id"], "IOS-123")
    }

    func test_merging_otherTakesPriorityOnCollidingKey() {
        let base: HTTPHeaders = ["X-App-Version": "default-value"]
        let override: HTTPHeaders = ["X-App-Version": "custom-value"]

        let merged = base.merging(override)

        XCTAssertEqual(merged["X-App-Version"], "custom-value")
    }
}
