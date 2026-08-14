import DomainInterfaces
import GeneralInterfaces
import UIKit

public enum RecipeModuleFactory {
    public enum EntryPoint {
        case creation
        case myRecipes
    }

    @MainActor
    // swiftlint:disable:next function_parameter_count
    public static func makeCoordinator(
        navigationController: UINavigationController,
        entryPoint: EntryPoint,
        getRecipeQuestionsUseCase: GetRecipeQuestionsUseCaseProtocol,
        generateRecipeUseCase: GenerateRecipeUseCaseProtocol,
        saveRecipeUseCase: SaveRecipeUseCaseProtocol,
        getSavedRecipesUseCase: GetSavedRecipesUseCaseProtocol,
        getSavedRecipeUseCase: GetSavedRecipeUseCaseProtocol,
        removeSavedRecipeUseCase: RemoveSavedRecipeUseCaseProtocol,
        onFinish: @escaping () -> Void = {}
    ) -> CoordinatorProtocol {
        RecipeCoordinator(
            navigationController: navigationController,
            entryPoint: entryPoint,
            getRecipeQuestionsUseCase: getRecipeQuestionsUseCase,
            generateRecipeUseCase: generateRecipeUseCase,
            saveRecipeUseCase: saveRecipeUseCase,
            getSavedRecipesUseCase: getSavedRecipesUseCase,
            getSavedRecipeUseCase: getSavedRecipeUseCase,
            removeSavedRecipeUseCase: removeSavedRecipeUseCase,
            onFinish: onFinish
        )
    }
}
