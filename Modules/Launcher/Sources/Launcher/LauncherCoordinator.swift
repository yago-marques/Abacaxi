import GeneralInterfaces
import UIKit

public final class LauncherCoordinator: CoordinatorProtocol {
    private static let minimumDisplayDuration: TimeInterval = 2

    public let navigationController: UINavigationController
    public weak var parentCoordinator: CoordinatorProtocol?

    private let useCaseContainer: UseCaseContainer
    private var launcherViewController: LauncherViewController?
    private var isExitScheduled = false

    public init(navigationController: UINavigationController, useCaseContainer: UseCaseContainer) {
        self.navigationController = navigationController
        self.useCaseContainer = useCaseContainer
    }

    public func start() {
        let launcherViewController = LauncherFactory.makeViewController(
            useCaseContainer: useCaseContainer,
            coordinator: self
        )
        launcherViewController.didFinishExpansion = { [weak self] in
            self?.parentCoordinator?.handle(CloseFlowAction())
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
