import Extensions
import GeneralInterfaces
import UIKit

public final class HomeCoordinator: CoordinatorProtocol {
    public let navigationController: UINavigationController
    public weak var parentCoordinator: CoordinatorProtocol?

    private let useCaseContainer: UseCaseContainer

    public init(
        navigationController: UINavigationController,
        useCaseContainer: UseCaseContainer
    ) {
        self.navigationController = navigationController
        self.useCaseContainer = useCaseContainer
    }

    public func start() {
        showOnboarding()
    }

    public func handle(_ action: CoordinatorActionProtocol) {
        guard let action = action as? HomeAction else { return }

        switch action {
        case .openHome:
            showHome()
        case .openOnboarding:
            guard !(navigationController.viewControllers.first is OnboardingViewController) else { return }
            showOnboarding()
        }
    }

    private func showHome() {
        let homeViewController = HomeFactory.makeViewController(useCaseContainer: useCaseContainer)
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
