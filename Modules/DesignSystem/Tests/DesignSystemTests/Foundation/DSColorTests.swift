import XCTest
@testable import DesignSystem

final class DSColorTests: XCTestCase {
    func test_primary_hasOpaqueAlpha() {
        XCTAssertEqual(DSColor.primary.cgColor.alpha, 1)
    }
}
