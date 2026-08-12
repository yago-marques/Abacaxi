import Extensions
import GeneralInterfaces
import UIKit

final class AppCoordinator: CoordinatorProtocol {
    let navigationController = UINavigationController()
    var parentCoordinator: CoordinatorProtocol?

    private let makeLauncherCoordinator: (UINavigationController, CoordinatorProtocol) -> CoordinatorProtocol
    private let makeHomeCoordinator: (UINavigationController, CoordinatorProtocol) -> CoordinatorProtocol
    private var childCoordinator: CoordinatorProtocol?

    init(
        makeLauncherCoordinator: @escaping (UINavigationController, CoordinatorProtocol) -> CoordinatorProtocol,
        makeHomeCoordinator: @escaping (UINavigationController, CoordinatorProtocol) -> CoordinatorProtocol
    ) {
        self.makeLauncherCoordinator = makeLauncherCoordinator
        self.makeHomeCoordinator = makeHomeCoordinator
    }

    func start() {
        navigationController.setNavigationBarHidden(true, animated: false)
        startLauncher()
    }

    func handle(_ action: CoordinatorActionProtocol) {
        if action is CloseFlowAction {
            startHome()
            return
        }
    }

    private func startLauncher() {
        let launcherCoordinator = makeLauncherCoordinator(navigationController, self)
        childCoordinator = launcherCoordinator
        launcherCoordinator.start()
    }

    private func startHome() {
        let homeCoordinator = makeHomeCoordinator(navigationController, self)
        childCoordinator = homeCoordinator
        navigationController.view.transition(.crossDissolve) { [homeCoordinator] in
            homeCoordinator.start()
        }
    }
}
