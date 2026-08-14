import UIKit

public protocol CoordinatorProtocol: AnyObject {
    var navigationController: UINavigationController { get }

    func start()
    func handle(_ action: CoordinatorActionProtocol)
}

public extension CoordinatorProtocol {
    func handle(_ action: CoordinatorActionProtocol) {}
}
