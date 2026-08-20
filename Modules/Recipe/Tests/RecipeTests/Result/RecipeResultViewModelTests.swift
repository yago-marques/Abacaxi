import DomainInterfaces
import Testing
@testable import Recipe

@MainActor
struct RecipeResultViewModelTests {
    @Test func save_whenUseCaseSucceeds_marksSavedAndForwardsRecipe() async {
        let recipe = makeRecipe()
        let (sut, doubles) = makeSUTAndDoubles(recipe: recipe)

        sut.save()
        let task = sut.saveTask
        await task?.value

        #expect(sut.isSaved)
        #expect(!sut.isSaving)
        #expect(!sut.didFailSaving)
        #expect(doubles.saveUseCase.receivedRecipes == [recipe])
    }

    @Test func save_whenUseCaseFails_exposesFailureAndAllowsRetry() async {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.saveUseCase.stubbedResult = .failure(StubError.failure)

        sut.save()
        let failedTask = sut.saveTask
        await failedTask?.value

        #expect(sut.didFailSaving)
        #expect(!sut.isSaved)
        #expect(!sut.isSaving)

        doubles.saveUseCase.stubbedResult = .success(())
        sut.save()
        let retryTask = sut.saveTask
        await retryTask?.value

        #expect(sut.isSaved)
        #expect(!sut.didFailSaving)
        #expect(doubles.saveUseCase.receivedRecipes.count == 2)
    }

    @Test func save_whenAlreadySaved_ignoresNewRequests() async {
        let (sut, doubles) = makeSUTAndDoubles()

        sut.save()
        let task = sut.saveTask
        sut.save()
        await task?.value

        #expect(doubles.saveUseCase.receivedRecipes.count == 1)
    }

    @Test func saveTitle_reflectsSaveState() async {
        let (sut, _) = makeSUTAndDoubles()

        #expect(sut.saveTitle == L10n.RecipeResult.save)

        sut.save()
        let task = sut.saveTask
        await task?.value

        #expect(sut.saveTitle == L10n.RecipeResult.saved)
    }

    @Test func remove_whenUseCaseSucceeds_marksRemovedAndUsesRecipeID() async {
        let (sut, doubles) = makeSUTAndDoubles()

        sut.remove(id: "saved-recipe")
        let task = sut.removeTask
        await task?.value

        #expect(sut.didRemove)
        #expect(doubles.removeUseCase.receivedIDs == ["saved-recipe"])
    }

    @Test func remove_whenUseCaseFails_exposesFailure() async {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.removeUseCase.stubbedResult = .failure(RemoveSavedRecipeError.persistenceFailed)

        sut.remove(id: "saved-recipe")
        let task = sut.removeTask
        await task?.value

        #expect(sut.didFailRemoving)
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
