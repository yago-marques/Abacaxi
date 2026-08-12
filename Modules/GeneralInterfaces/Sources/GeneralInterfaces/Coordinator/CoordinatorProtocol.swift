import UIKit

public protocol CoordinatorProtocol: AnyObject {
    var navigationController: UINavigationController { get }
    var parentCoordinator: CoordinatorProtocol? { get set }

    func start()
    func handle(_ action: CoordinatorActionProtocol)
}

public extension CoordinatorProtocol {
    func handle(_ action: CoordinatorActionProtocol) {}
}
