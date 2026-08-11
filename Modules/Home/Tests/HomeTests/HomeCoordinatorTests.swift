import GeneralInterfaces
import XCTest
@testable import Home

final class HomeCoordinatorTests: XCTestCase {
    private struct OtherAction: CoordinatorAction {}

    func test_start_presentsHomeViewControllerOnNavigationStack() {
        let navigationController = UINavigationController()
        let sut = HomeCoordinator(navigationController: navigationController)

        sut.start()

        XCTAssertTrue(navigationController.viewControllers.first is HomeViewController)
    }

    func test_handle_ignoresActionsThatAreNotHomeAction() {
        let navigationController = UINavigationController()
        let sut = HomeCoordinator(navigationController: navigationController)

        sut.handle(OtherAction())
    }

    func test_handle_acceptsHomeAction() {
        let navigationController = UINavigationController()
        let sut = HomeCoordinator(navigationController: navigationController)

        sut.handle(HomeAction.didAppear)
    }
}
