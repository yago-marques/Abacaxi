import DomainInterfaces
import Testing
@testable import Recipe

@MainActor
struct SavedRecipesViewModelTests {
    @Test func load_whenRecipesExist_exposesContentState() async {
        let useCase = GetSavedRecipesUseCaseStub()
        useCase.stubbedResult = .success([recipe])
        let sut = SavedRecipesViewModel(getSavedRecipesUseCase: useCase)

        sut.load()
        let task = sut.loadTask
        await task?.value

        #expect(sut.state == .content([SavedRecipePresentationModel(recipe)]))
    }

    @Test func load_whenHistoryIsEmpty_exposesEmptyState() async {
        let sut = SavedRecipesViewModel(getSavedRecipesUseCase: GetSavedRecipesUseCaseStub())

        sut.load()
        let task = sut.loadTask
        await task?.value

        #expect(sut.state == .empty)
    }

    @Test func load_whenQueryFails_exposesErrorState() async {
        let useCase = GetSavedRecipesUseCaseStub()
        useCase.stubbedResult = .failure(GetSavedRecipesError.persistenceFailed)
        let sut = SavedRecipesViewModel(getSavedRecipesUseCase: useCase)

        sut.load()
        let task = sut.loadTask
        await task?.value

        #expect(sut.state == .error)
    }

    private var recipe: SavedRecipeBusinessModel {
        SavedRecipeBusinessModel(
            id: "1",
            title: "Macarrão",
            description: "Receita simples",
            preparationTimeMinutes: 20,
            servings: 2,
            imagePath: nil
        )
    }
}
