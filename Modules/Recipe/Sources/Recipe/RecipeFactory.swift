import DomainInterfaces
import SwiftUI
import UIKit

enum RecipeFactory {
    @MainActor
    // swiftlint:disable:next function_parameter_count
    static func makeFlowViewController(
        entryPoint: RecipeModuleFactory.EntryPoint,
        getRecipeQuestionsUseCase: GetRecipeQuestionsUseCaseProtocol,
        generateRecipeUseCase: GenerateRecipeUseCaseProtocol,
        saveRecipeUseCase: SaveRecipeUseCaseProtocol,
        getSavedRecipesUseCase: GetSavedRecipesUseCaseProtocol,
        getSavedRecipeUseCase: GetSavedRecipeUseCaseProtocol,
        removeSavedRecipeUseCase: RemoveSavedRecipeUseCaseProtocol,
        onFinish: @escaping () -> Void,
        onDismiss: @escaping () -> Void = {}
    ) -> UIViewController {
        UIHostingController(
            rootView: RecipeFlowView(
                entryPoint: entryPoint,
                getRecipeQuestionsUseCase: getRecipeQuestionsUseCase,
                generateRecipeUseCase: generateRecipeUseCase,
                saveRecipeUseCase: saveRecipeUseCase,
                getSavedRecipesUseCase: getSavedRecipesUseCase,
                getSavedRecipeUseCase: getSavedRecipeUseCase,
                removeSavedRecipeUseCase: removeSavedRecipeUseCase,
                onFinish: onFinish,
                onDismiss: onDismiss
            )
        )
    }
}
