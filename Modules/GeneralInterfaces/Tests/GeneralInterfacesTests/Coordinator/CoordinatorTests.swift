import XCTest
@testable import GeneralInterfaces

@MainActor
final class CoordinatorTests: XCTestCase {
    private struct StubAction: CoordinatorActionProtocol {}

    func test_start_marksCoordinatorAsStarted() {
        let sut = makeSUT()

        sut.start()

        XCTAssertTrue(sut.startCalled)
    }

    func test_handle_receivesTheGivenAction() {
        let sut = makeSUT()
        let action = StubAction()

        sut.handle(action)

        XCTAssertNotNil(sut.handledAction)
    }
}

private extension CoordinatorTests {
    private typealias SUT = CoordinatorStub

    private func makeSUT() -> SUT {
        CoordinatorStub()
    }
}
