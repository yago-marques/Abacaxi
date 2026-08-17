import GeneralInterfaces
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let appCoordinator = CompositionRoot.makeAppCoordinator()
        appCoordinator.start()
        self.appCoordinator = appCoordinator

        let window = makeWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .dark
        window.rootViewController = appCoordinator.navigationController
        window.makeKeyAndVisible()
        self.window = window
    }
}

private extension SceneDelegate {
    func makeWindow(windowScene: UIWindowScene) -> UIWindow {
        let configuration = DebugMenuConfiguration()
        guard configuration.isEnabled else {
            return UIWindow(windowScene: windowScene)
        }

        return DebugMenuWindow(windowScene: windowScene, configuration: configuration)
    }
}
