import XCTest
@testable import GeneralInterfaces

final class ViewCodingTests: XCTestCase {
    func test_buildLayout_callsSetupViewThenHierarchyThenConstraintsInOrder() {
        let sut = makeSUT()

        sut.buildLayout()

        XCTAssertEqual(sut.calledMethods, ["setupView()", "setupHierarchy()", "setupConstraints()"])
    }
}

private extension ViewCodingTests {
    private typealias SUT = ViewCodingSpy

    private func makeSUT() -> SUT {
        ViewCodingSpy()
    }
}
