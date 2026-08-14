import GeneralInterfaces
import UIKit

public final class LauncherCoordinator: CoordinatorProtocol {
    private static let minimumDisplayDuration: TimeInterval = 2

    public let navigationController: UINavigationController

    private let useCaseContainer: UseCaseContainer
    private let onFinish: () -> Void
    private var launcherViewController: LauncherViewController?
    private var isExitScheduled = false

    public init(
        navigationController: UINavigationController,
        useCaseContainer: UseCaseContainer,
        onFinish: @escaping () -> Void
    ) {
        self.navigationController = navigationController
        self.useCaseContainer = useCaseContainer
        self.onFinish = onFinish
    }

    public func start() {
        let launcherViewController = LauncherFactory.makeViewController(
            useCaseContainer: useCaseContainer,
            coordinator: self
        )
        launcherViewController.didFinishExpansion = { [onFinish] in
            onFinish()
        }
        self.launcherViewController = launcherViewController
        navigationController.setViewControllers([launcherViewController], animated: false)
    }

    public func handle(_ action: CoordinatorActionProtocol) {
        guard let action = action as? LauncherAction else { return }

        switch action {
        case .closeLauncher:
            scheduleExitAnimation()
        }
    }

    private func scheduleExitAnimation() {
        guard !isExitScheduled else { return }
        isExitScheduled = true

        DispatchQueue.main.asyncAfter(deadline: .now() + Self.minimumDisplayDuration) { [weak self] in
            self?.launcherViewController?.closeLauncher()
        }
    }
}
