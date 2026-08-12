import DomainInterfaces
import GeneralInterfaces
import XCTest
@testable import Home

final class HomeCoordinatorTests: XCTestCase {
    private struct OtherAction: CoordinatorActionProtocol {}

    func test_start_whenFirstAccess_presentsOnboardingViewControllerOnNavigationStack() {
        let (sut, doubles) = makeSUTAndDoubles()

        sut.start()

        XCTAssertTrue(doubles.navigationController.viewControllers.first is OnboardingViewController)
    }

    func test_handle_ignoresActionsThatAreNotHomeAction() {
        let (sut, _) = makeSUTAndDoubles()

        sut.handle(OtherAction())
    }

    func test_handle_whenOpeningHome_presentsHomeViewControllerOnNavigationStack() {
        let (sut, doubles) = makeSUTAndDoubles()

        sut.handle(HomeAction.openHome)

        XCTAssertTrue(doubles.navigationController.viewControllers.first is HomeViewController)
    }

    func test_handle_whenOpeningOnboarding_presentsOnboardingViewControllerOnNavigationStack() {
        let (sut, doubles) = makeSUTAndDoubles()

        sut.handle(HomeAction.openOnboarding)

        XCTAssertTrue(doubles.navigationController.viewControllers.first is OnboardingViewController)
    }
}

private extension HomeCoordinatorTests {
    private typealias SUT = HomeCoordinator
    private typealias Doubles = (
        navigationController: UINavigationController,
        shouldShowOnboardingUseCase: ShouldShowOnboardingUseCaseStub,
        completeOnboardingUseCase: CompleteOnboardingUseCaseSpy,
        getRemainingAttemptsUseCase: GetRemainingAttemptsUseCaseStub
    )

    private func makeSUTAndDoubles() -> (sut: SUT, doubles: Doubles) {
        let navigationController = UINavigationController()
        let shouldShowOnboardingUseCase = ShouldShowOnboardingUseCaseStub()
        let completeOnboardingUseCase = CompleteOnboardingUseCaseSpy()
        let getRemainingAttemptsUseCase = GetRemainingAttemptsUseCaseStub()
        getRemainingAttemptsUseCase.stubbedResult = .success(
            RemainingAttempts(remaining: 17, limit: 20, windowSeconds: 3_600)
        )
        let useCaseContainer = UseCaseContainer()
        useCaseContainer.registerSingleton(
            ShouldShowOnboardingUseCaseProtocol.self,
            instance: shouldShowOnboardingUseCase
        )
        useCaseContainer.registerSingleton(
            CompleteOnboardingUseCaseProtocol.self,
            instance: completeOnboardingUseCase
        )
        useCaseContainer.registerSingleton(
            GetRemainingAttemptsUseCaseProtocol.self,
            instance: getRemainingAttemptsUseCase
        )
        let sut = HomeCoordinator(
            navigationController: navigationController,
            useCaseContainer: useCaseContainer
        )
        return (
            sut,
            (
                navigationController,
                shouldShowOnboardingUseCase,
                completeOnboardingUseCase,
                getRemainingAttemptsUseCase
            )
        )
    }
}
