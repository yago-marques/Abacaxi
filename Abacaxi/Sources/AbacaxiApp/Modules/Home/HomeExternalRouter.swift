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

    func openRecipeCreation() -> CoordinatorProtocol {
        RecipeModule.start(
            navigationController: navigationController,
            entryPoint: .creation,
            useCaseContainer: useCaseContainer
        )
    }

    func openSavedRecipes() -> CoordinatorProtocol {
        RecipeModule.start(navigationController: navigationController, entryPoint: .myRecipes, useCaseContainer: useCaseContainer)
    }
}
