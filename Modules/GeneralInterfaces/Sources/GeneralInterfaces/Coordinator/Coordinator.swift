import UIKit

public protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }

    func start()
    func handle(_ action: CoordinatorAction)
}
