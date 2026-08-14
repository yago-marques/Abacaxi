import Extensions
import GeneralInterfaces
import UIKit

final class AppCoordinator: CoordinatorProtocol {
    let navigationController = UINavigationController()

    private let makeLauncherCoordinator: (UINavigationController, @escaping () -> Void) -> CoordinatorProtocol
    private let makeHomeCoordinator: (UINavigationController) -> CoordinatorProtocol
    private var childCoordinator: CoordinatorProtocol?

    init(
        makeLauncherCoordinator: @escaping (UINavigationController, @escaping () -> Void) -> CoordinatorProtocol,
        makeHomeCoordinator: @escaping (UINavigationController) -> CoordinatorProtocol
    ) {
        self.makeLauncherCoordinator = makeLauncherCoordinator
        self.makeHomeCoordinator = makeHomeCoordinator
    }

    func start() {
        navigationController.setNavigationBarHidden(true, animated: false)
        startLauncher()
    }

    private func startLauncher() {
        let launcherCoordinator = makeLauncherCoordinator(navigationController) { [weak self] in
            self?.startHome()
        }
        childCoordinator = launcherCoordinator
        launcherCoordinator.start()
    }

    private func startHome() {
        navigationController.view.transition(.crossDissolve) { [self] in
            childCoordinator = makeHomeCoordinator(navigationController)
        }
    }
}
