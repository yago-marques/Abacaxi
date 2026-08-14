import DomainInterfaces
import Testing
@testable import Recipe

@MainActor
struct RecipeResultViewModelTests {
    @Test func remove_whenUseCaseSucceeds_returnsTrueAndUsesRecipeID() {
        let removeUseCase = RemoveSavedRecipeUseCaseStub()
        let sut = makeSUT(removeUseCase: removeUseCase)

        let didRemove = sut.remove(id: "saved-recipe")

        #expect(didRemove)
        #expect(removeUseCase.receivedIDs == ["saved-recipe"])
    }

    @Test func remove_whenUseCaseFails_returnsFalse() {
        let removeUseCase = RemoveSavedRecipeUseCaseStub()
        removeUseCase.stubbedResult = .failure(RemoveSavedRecipeError.persistenceFailed)
        let sut = makeSUT(removeUseCase: removeUseCase)

        #expect(!sut.remove(id: "saved-recipe"))
    }

    private func makeSUT(removeUseCase: RemoveSavedRecipeUseCaseStub) -> RecipeResultViewModel {
        RecipeResultViewModel(
            recipe: RecipeBusinessModel(
                title: "Receita",
                description: "Descrição",
                ingredients: [],
                steps: [],
                preparationTimeMinutes: 20,
                servings: 2,
                nutrition: nil,
                imageData: nil
            ),
            saveRecipeUseCase: SaveRecipeUseCaseSpy(),
            removeSavedRecipeUseCase: removeUseCase
        )
    }
}
