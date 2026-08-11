import GeneralInterfaces
import UIKit

public final class HomeCoordinator: Coordinator {
    public let navigationController: UINavigationController
    public weak var parentCoordinator: Coordinator?

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    public func start() {
        navigationController.setViewControllers([HomeViewController()], animated: false)
    }

    public func handle(_ action: CoordinatorAction) {
        guard let action = action as? HomeAction else { return }

        switch action {
        case .didAppear:
            break
        }
    }
}
