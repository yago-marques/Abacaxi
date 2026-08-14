import Extensions
import GeneralInterfaces
import UIKit

final class HomeCoordinator: CoordinatorProtocol {
    let navigationController: UINavigationController

    private let useCaseContainer: UseCaseContainer
    private let externalRouter: HomeExternalRouterProtocol
    private var childCoordinator: CoordinatorProtocol?

    init(
        navigationController: UINavigationController,
        useCaseContainer: UseCaseContainer,
        externalRouter: HomeExternalRouterProtocol
    ) {
        self.navigationController = navigationController
        self.useCaseContainer = useCaseContainer
        self.externalRouter = externalRouter
    }

    func start() {
        showOnboarding()
    }

    func handle(_ action: CoordinatorActionProtocol) {
        guard let action = action as? HomeAction else { return }

        switch action {
        case .openHome:
            showHome()
        case .openOnboarding:
            guard !(navigationController.viewControllers.first is OnboardingViewController) else { return }
            showOnboarding()
        case .openRecipeCreation:
            childCoordinator = externalRouter.openRecipeCreation()
        case .openSavedRecipes:
            childCoordinator = externalRouter.openSavedRecipes()
        }
    }

    private func showHome() {
        let homeViewController = HomeFactory.makeViewController(
            useCaseContainer: useCaseContainer,
            coordinator: self
        )
        navigationController.view.transition(.crossDissolve) { [navigationController, homeViewController] in
            navigationController.setViewControllers([homeViewController], animated: false)
        }
    }

    private func showOnboarding() {
        let onboardingViewController = OnboardingFactory.makeViewController(
            useCaseContainer: useCaseContainer,
            coordinator: self
        )
        navigationController.setViewControllers([onboardingViewController], animated: false)
    }
}
