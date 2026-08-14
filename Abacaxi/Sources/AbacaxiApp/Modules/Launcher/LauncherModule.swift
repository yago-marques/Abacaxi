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
        useCaseContainer: UseCaseContainer,
        onFinish: @escaping () -> Void
    ) -> CoordinatorProtocol {
        let coordinator = LauncherCoordinator(
            navigationController: navigationController,
            useCaseContainer: useCaseContainer,
            onFinish: onFinish
        )
        return coordinator
    }
}
