import XCTest
import NetworkInterfaces
@testable import Network

final class HeaderResolutionTests: XCTestCase {
    func test_resolve_keepsDefaultsWhenRequestHasNoOverrides() {
        let defaults: HTTPHeaders = ["X-App-Version": "1.0", "X-Correlation-Id": "IOS-abc"]

        let resolved = HeaderResolution.resolve(requestHeaders: [:], defaults: defaults, hasBody: false)

        XCTAssertEqual(resolved["X-App-Version"], "1.0")
        XCTAssertEqual(resolved["X-Correlation-Id"], "IOS-abc")
    }

    func test_resolve_requestHeaderOverridesDefault() {
        let defaults: HTTPHeaders = ["X-App-Version": "default-value"]
        let requestHeaders: HTTPHeaders = ["X-App-Version": "custom-value"]

        let resolved = HeaderResolution.resolve(requestHeaders: requestHeaders, defaults: defaults, hasBody: false)

        XCTAssertEqual(resolved["X-App-Version"], "custom-value")
    }

    func test_resolve_addsJSONContentTypeWhenBodyPresentAndNotSet() {
        let resolved = HeaderResolution.resolve(requestHeaders: [:], defaults: [:], hasBody: true)

        XCTAssertEqual(resolved["Content-Type"], "application/json")
    }

    func test_resolve_doesNotOverrideExplicitContentType() {
        let requestHeaders: HTTPHeaders = ["Content-Type": "application/xml"]

        let resolved = HeaderResolution.resolve(requestHeaders: requestHeaders, defaults: [:], hasBody: true)

        XCTAssertEqual(resolved["Content-Type"], "application/xml")
    }

    func test_resolve_omitsContentTypeWhenNoBody() {
        let resolved = HeaderResolution.resolve(requestHeaders: [:], defaults: [:], hasBody: false)

        XCTAssertNil(resolved["Content-Type"])
    }
}
