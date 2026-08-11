import GeneralInterfaces
import Home
import UIKit

final class AppCoordinator: Coordinator {
    let navigationController = UINavigationController()

    private var homeCoordinator: HomeCoordinator?

    func start() {
        let homeCoordinator = HomeCoordinator(navigationController: navigationController)
        homeCoordinator.parentCoordinator = self
        self.homeCoordinator = homeCoordinator
        homeCoordinator.start()
    }

    func handle(_ action: CoordinatorAction) {
        guard let action = action as? AppAction else { return }
        switch action {}
    }
}
