import GeneralInterfaces
import UIKit

public enum HomeModuleFactory {
    public static func makeCoordinator(
        navigationController: UINavigationController,
        useCaseContainer: UseCaseContainer,
        externalRouter: HomeExternalRouterProtocol
    ) -> CoordinatorProtocol {
        HomeCoordinator(
            navigationController: navigationController,
            useCaseContainer: useCaseContainer,
            externalRouter: externalRouter
        )
    }
}
