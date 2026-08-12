import DomainInterfaces
import GeneralInterfaces
import Launcher
import UIKit

enum LauncherModule {
    static func registerDependencies(in container: UseCaseContainer) {
        container.register(CreateDeviceIDUseCaseProtocol.self) {
            CreateDeviceIDUseCaseBuilder.make()
        }
        container.register(GetDeviceIDUseCaseProtocol.self) {
            GetDeviceIDUseCaseBuilder.make()
        }
    }

    static func makeCoordinator(
        navigationController: UINavigationController,
        parent: CoordinatorProtocol,
        useCaseContainer: UseCaseContainer
    ) -> CoordinatorProtocol {
        let coordinator = LauncherCoordinator(
            navigationController: navigationController,
            useCaseContainer: useCaseContainer
        )
        coordinator.parentCoordinator = parent
        return coordinator
    }
}
