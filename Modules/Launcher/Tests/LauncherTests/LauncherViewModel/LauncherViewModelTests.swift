import XCTest
@testable import Launcher

final class LauncherViewModelTests: XCTestCase {
    func test_checkDeviceID_withAnExistingID_doesNotCreateAndSignalsCompletion() {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.getDeviceIDUseCase.stubbedID = UUID()

        sut.checkDeviceID()

        XCTAssertEqual(doubles.createDeviceIDUseCase.executeCallCount, 0)
        XCTAssertEqual(doubles.coordinator.receivedAction, .closeLauncher)
    }

    func test_checkDeviceID_withNoExistingID_createsOneAndSignalsCompletion() {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.getDeviceIDUseCase.stubbedID = nil

        sut.checkDeviceID()

        XCTAssertEqual(doubles.createDeviceIDUseCase.executeCallCount, 1)
        XCTAssertEqual(doubles.coordinator.receivedAction, .closeLauncher)
    }
}

private extension LauncherViewModelTests {
    private typealias SUT = LauncherViewModel
    private typealias Doubles = (
        getDeviceIDUseCase: GetDeviceIDUseCaseStub,
        createDeviceIDUseCase: CreateDeviceIDUseCaseStub,
        coordinator: LauncherCoordinatorSpy
    )

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
