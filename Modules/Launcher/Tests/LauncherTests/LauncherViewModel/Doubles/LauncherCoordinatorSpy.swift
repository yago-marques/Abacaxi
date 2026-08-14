import GeneralInterfaces
@testable import Launcher
import UIKit

final class LauncherCoordinatorSpy: CoordinatorProtocol {
    let navigationController = UINavigationController()

    private(set) var receivedAction: LauncherAction?

    func start() {}

    func handle(_ action: CoordinatorActionProtocol) {
        receivedAction = action as? LauncherAction
    }
}
