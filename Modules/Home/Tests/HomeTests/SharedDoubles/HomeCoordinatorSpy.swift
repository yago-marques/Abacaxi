import GeneralInterfaces
import UIKit
@testable import Home

final class HomeCoordinatorSpy: CoordinatorProtocol {
    let navigationController = UINavigationController()
    weak var parentCoordinator: CoordinatorProtocol?

    private(set) var receivedAction: HomeAction?

    func start() {}

    func handle(_ action: CoordinatorActionProtocol) {
        receivedAction = action as? HomeAction
    }
}
