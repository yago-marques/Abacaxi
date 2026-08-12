import XCTest
@testable import Home

final class OnboardingViewModelTests: XCTestCase {
    func test_start_whenOnboardingIsNotCompleted_opensOnboarding() {
        let (sut, doubles) = makeSUTAndDoubles()

        sut.start()

        XCTAssertEqual(doubles.coordinator.receivedAction, .openOnboarding)
    }

    func test_start_whenOnboardingIsCompleted_opensHome() {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.shouldShowOnboardingUseCase.executeReturn = false

        sut.start()

        XCTAssertEqual(doubles.coordinator.receivedAction, .openHome)
    }

    func test_didTapStart_persistsCompletionAndOpensHome() {
        let (sut, doubles) = makeSUTAndDoubles()

        sut.didTapStart()

        XCTAssertTrue(doubles.completeOnboardingUseCase.executeCalled)
        XCTAssertEqual(doubles.coordinator.receivedAction, .openHome)
    }
}

private extension OnboardingViewModelTests {
    private typealias SUT = OnboardingViewModel
    private typealias Doubles = (
        shouldShowOnboardingUseCase: ShouldShowOnboardingUseCaseStub,
        completeOnboardingUseCase: CompleteOnboardingUseCaseSpy,
        coordinator: HomeCoordinatorSpy
    )

    private func makeSUTAndDoubles() -> (sut: SUT, doubles: Doubles) {
        let shouldShowOnboardingUseCase = ShouldShowOnboardingUseCaseStub()
        let completeOnboardingUseCase = CompleteOnboardingUseCaseSpy()
        let coordinator = HomeCoordinatorSpy()
        let sut = OnboardingViewModel(
            shouldShowOnboardingUseCase: shouldShowOnboardingUseCase,
            completeOnboardingUseCase: completeOnboardingUseCase,
            coordinator: coordinator
        )
        return (sut, (shouldShowOnboardingUseCase, completeOnboardingUseCase, coordinator))
    }
}
