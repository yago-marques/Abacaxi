import GeneralInterfaces
import Home
import Recipe
import UIKit

final class HomeExternalRouter: HomeExternalRouterProtocol {
    private let navigationController: UINavigationController
    private let useCaseContainer: UseCaseContainer

    init(navigationController: UINavigationController, useCaseContainer: UseCaseContainer) {
        self.navigationController = navigationController
        self.useCaseContainer = useCaseContainer
    }

    func openRecipeCreation(onFinish: @escaping () -> Void) -> CoordinatorProtocol {
        RecipeModule.start(
            navigationController: navigationController,
            entryPoint: .creation,
            useCaseContainer: useCaseContainer,
            onFinish: onFinish
        )
    }

    func openSavedRecipes(onFinish: @escaping () -> Void) -> CoordinatorProtocol {
        RecipeModule.start(
            navigationController: navigationController,
            entryPoint: .myRecipes,
            useCaseContainer: useCaseContainer,
            onFinish: onFinish
        )
    }
}
