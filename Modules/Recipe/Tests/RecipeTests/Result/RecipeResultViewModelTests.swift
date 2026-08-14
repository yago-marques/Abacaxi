import DomainInterfaces
import Testing
@testable import Recipe

@MainActor
struct RecipeResultViewModelTests {
    @Test func save_whenUseCaseSucceeds_marksSavedAndForwardsRecipe() {
        let recipe = makeRecipe()
        let (sut, doubles) = makeSUTAndDoubles(recipe: recipe)

        sut.save()

        #expect(sut.isSaved)
        #expect(!sut.isSaving)
        #expect(!sut.didFailSaving)
        #expect(doubles.saveUseCase.receivedRecipes == [recipe])
    }

    @Test func save_whenUseCaseFails_exposesFailureAndAllowsRetry() {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.saveUseCase.stubbedResult = .failure(StubError.failure)

        sut.save()

        #expect(sut.didFailSaving)
        #expect(!sut.isSaved)
        #expect(!sut.isSaving)

        doubles.saveUseCase.stubbedResult = .success(())
        sut.save()

        #expect(sut.isSaved)
        #expect(!sut.didFailSaving)
        #expect(doubles.saveUseCase.receivedRecipes.count == 2)
    }

    @Test func save_whenAlreadySaved_ignoresNewRequests() {
        let (sut, doubles) = makeSUTAndDoubles()

        sut.save()
        sut.save()

        #expect(doubles.saveUseCase.receivedRecipes.count == 1)
    }

    @Test func saveTitle_reflectsSaveState() {
        let (sut, _) = makeSUTAndDoubles()

        #expect(sut.saveTitle == L10n.RecipeResult.save)

        sut.save()

        #expect(sut.saveTitle == L10n.RecipeResult.saved)
    }

    @Test func remove_whenUseCaseSucceeds_returnsTrueAndUsesRecipeID() {
        let (sut, doubles) = makeSUTAndDoubles()

        let didRemove = sut.remove(id: "saved-recipe")

        #expect(didRemove)
        #expect(doubles.removeUseCase.receivedIDs == ["saved-recipe"])
    }

    @Test func remove_whenUseCaseFails_returnsFalse() {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.removeUseCase.stubbedResult = .failure(RemoveSavedRecipeError.persistenceFailed)

        #expect(!sut.remove(id: "saved-recipe"))
    }
}

private extension RecipeResultViewModelTests {
    private typealias SUT = RecipeResultViewModel
    private typealias Doubles = (saveUseCase: SaveRecipeUseCaseSpy, removeUseCase: RemoveSavedRecipeUseCaseStub)

    private enum StubError: Error {
        case failure
    }

    private func makeRecipe() -> RecipeBusinessModel {
        RecipeBusinessModel(
            title: "Receita",
            description: "Descrição",
            ingredients: [],
            steps: [],
            preparationTimeMinutes: 20,
            servings: 2,
            nutrition: nil,
            imageData: nil
        )
    }

    private func makeSUTAndDoubles(recipe: RecipeBusinessModel? = nil) -> (sut: SUT, doubles: Doubles) {
        let saveUseCase = SaveRecipeUseCaseSpy()
        let removeUseCase = RemoveSavedRecipeUseCaseStub()
        let sut = RecipeResultViewModel(
            recipe: recipe ?? makeRecipe(),
            saveRecipeUseCase: saveUseCase,
            removeSavedRecipeUseCase: removeUseCase
        )
        return (sut, (saveUseCase, removeUseCase))
    }
}
