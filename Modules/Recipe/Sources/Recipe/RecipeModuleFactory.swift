import DomainInterfaces
import GeneralInterfaces
import UIKit

public enum RecipeModuleFactory {
    public enum EntryPoint {
        case creation
        case myRecipes
    }

    public static func makeCoordinator(
        navigationController: UINavigationController,
        entryPoint: EntryPoint,
        getRecipeQuestionsUseCase: GetRecipeQuestionsUseCaseProtocol,
        generateRecipeUseCase: GenerateRecipeUseCaseProtocol,
        saveRecipeUseCase: SaveRecipeUseCaseProtocol,
        getSavedRecipesUseCase: GetSavedRecipesUseCaseProtocol,
        getSavedRecipeUseCase: GetSavedRecipeUseCaseProtocol,
        removeSavedRecipeUseCase: RemoveSavedRecipeUseCaseProtocol
    ) -> CoordinatorProtocol {
        RecipeCoordinator(
            navigationController: navigationController,
            entryPoint: entryPoint,
            getRecipeQuestionsUseCase: getRecipeQuestionsUseCase,
            generateRecipeUseCase: generateRecipeUseCase,
            saveRecipeUseCase: saveRecipeUseCase,
            getSavedRecipesUseCase: getSavedRecipesUseCase,
            getSavedRecipeUseCase: getSavedRecipeUseCase,
            removeSavedRecipeUseCase: removeSavedRecipeUseCase
        )
    }
}
