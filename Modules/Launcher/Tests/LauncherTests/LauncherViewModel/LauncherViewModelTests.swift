import XCTest
@testable import Launcher

@MainActor
final class LauncherViewModelTests: XCTestCase {
    func test_checkDeviceID_withAnExistingID_doesNotCreateAndSignalsCompletion() {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.getDeviceIDUseCase.stubbedResult = .success(UUID())

        sut.checkDeviceID()

        XCTAssertEqual(doubles.createDeviceIDUseCase.executeCallCount, 0)
        XCTAssertEqual(doubles.coordinator.receivedAction, .closeLauncher)
    }

    func test_checkDeviceID_withNoExistingID_createsOneAndSignalsCompletion() {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.getDeviceIDUseCase.stubbedResult = .success(nil)

        sut.checkDeviceID()

        XCTAssertEqual(doubles.createDeviceIDUseCase.executeCallCount, 1)
        XCTAssertEqual(doubles.coordinator.receivedAction, .closeLauncher)
    }

    func test_checkDeviceID_whenLookupFails_stillSignalsCompletion() {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.getDeviceIDUseCase.stubbedResult = .failure(StubError.failure)

        sut.checkDeviceID()

        XCTAssertEqual(doubles.coordinator.receivedAction, .closeLauncher)
    }

    func test_checkDeviceID_whenCreationFails_stillSignalsCompletion() {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.getDeviceIDUseCase.stubbedResult = .success(nil)
        doubles.createDeviceIDUseCase.stubbedResult = .failure(StubError.failure)

        sut.checkDeviceID()

        XCTAssertEqual(doubles.createDeviceIDUseCase.executeCallCount, 1)
        XCTAssertEqual(doubles.coordinator.receivedAction, .closeLauncher)
    }
}

private extension LauncherViewModelTests {
    private typealias SUT = LauncherViewModel
    // swiftlint:disable:next large_tuple
    private typealias Doubles = (
        getDeviceIDUseCase: GetDeviceIDUseCaseStub,
        createDeviceIDUseCase: CreateDeviceIDUseCaseStub,
        coordinator: LauncherCoordinatorSpy
    )

    private enum StubError: Error {
        case failure
    }

    private func makeSUTAndDoubles() -> (sut: SUT, doubles: Doubles) {
        let getDeviceIDUseCase = GetDeviceIDUseCaseStub()
        let createDeviceIDUseCase = CreateDeviceIDUseCaseStub()
        let coordinator = LauncherCoordinatorSpy()
        let sut = LauncherViewModel(
            getDeviceIDUseCase: getDeviceIDUseCase,
            createDeviceIDUseCase: createDeviceIDUseCase,
            coordinator: coordinator
        )
        return (sut, (getDeviceIDUseCase, createDeviceIDUseCase, coordinator))
    }
}
