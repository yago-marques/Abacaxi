import Testing
import SwiftUI
import UIKit
@testable import Recipe

@MainActor
struct RecipeCoordinatorTests {
    @Test func start_presentsIngredientPicker() {
        let navigationController = UINavigationController()
        let getRecipeQuestionsUseCase = GetRecipeQuestionsUseCaseStub()
        getRecipeQuestionsUseCase.stubbedResult = .success([])
        let sut = RecipeCoordinator(
            navigationController: navigationController,
            entryPoint: .creation,
            getRecipeQuestionsUseCase: getRecipeQuestionsUseCase,
            generateRecipeUseCase: GenerateRecipeUseCaseStub(),
            saveRecipeUseCase: SaveRecipeUseCaseSpy(),
            getSavedRecipesUseCase: GetSavedRecipesUseCaseStub(),
            getSavedRecipeUseCase: GetSavedRecipeUseCaseStub(),
            removeSavedRecipeUseCase: RemoveSavedRecipeUseCaseStub()
        )

        sut.start()

        #expect(navigationController.topViewController is UIHostingController<RecipeFlowView>)
    }
}
