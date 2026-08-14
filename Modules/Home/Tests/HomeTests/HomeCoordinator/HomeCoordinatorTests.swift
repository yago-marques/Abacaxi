import DomainInterfaces
import GeneralInterfaces
import XCTest
@testable import Home

@MainActor
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

    func test_handle_whenOpeningRecipeCreation_usesTheExternalRouter() {
        let (sut, doubles) = makeSUTAndDoubles()

        sut.handle(HomeAction.openRecipeCreation)

        XCTAssertTrue(doubles.externalRouter.openRecipeCreationCalled)
    }

    func test_handle_whenOpeningSavedRecipes_usesTheExternalRouter() {
        let (sut, doubles) = makeSUTAndDoubles()

        sut.handle(HomeAction.openSavedRecipes)

        XCTAssertTrue(doubles.externalRouter.openSavedRecipesCalled)
    }

    func test_handle_whenChildFlowFinishes_releasesTheChildCoordinator() {
        let (sut, doubles) = makeSUTAndDoubles()
        weak var childCoordinator = doubles.externalRouter.stubbedCoordinator

        sut.handle(HomeAction.openRecipeCreation)
        doubles.externalRouter.stubbedCoordinator = nil
        XCTAssertNotNil(childCoordinator)

        doubles.externalRouter.lastOnFinish?()

        XCTAssertNil(childCoordinator)
    }
}

private extension HomeCoordinatorTests {
    private typealias SUT = HomeCoordinator
    // swiftlint:disable:next large_tuple
    private typealias Doubles = (
        navigationController: UINavigationController,
        shouldShowOnboardingUseCase: ShouldShowOnboardingUseCaseStub,
        completeOnboardingUseCase: CompleteOnboardingUseCaseSpy,
        getRemainingAttemptsUseCase: GetRemainingAttemptsUseCaseStub,
        hasSavedRecipesUseCase: HasSavedRecipesUseCaseStub,
        externalRouter: HomeExternalRouterStub
    )

    private func makeSUTAndDoubles() -> (sut: SUT, doubles: Doubles) {
        let navigationController = UINavigationController()
        let shouldShowOnboardingUseCase = ShouldShowOnboardingUseCaseStub()
        let completeOnboardingUseCase = CompleteOnboardingUseCaseSpy()
        let getRemainingAttemptsUseCase = GetRemainingAttemptsUseCaseStub()
        let hasSavedRecipesUseCase = HasSavedRecipesUseCaseStub()
        let externalRouter = HomeExternalRouterStub()
        externalRouter.stubbedCoordinator = HomeCoordinatorSpy()
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
        useCaseContainer.registerSingleton(
            HasSavedRecipesUseCaseProtocol.self,
            instance: hasSavedRecipesUseCase
        )
        let sut = HomeCoordinator(
            navigationController: navigationController,
            useCaseContainer: useCaseContainer,
            externalRouter: externalRouter
        )
        return (
            sut,
            (
                navigationController,
                shouldShowOnboardingUseCase,
                completeOnboardingUseCase,
                getRemainingAttemptsUseCase,
                hasSavedRecipesUseCase,
                externalRouter
            )
        )
    }
}
