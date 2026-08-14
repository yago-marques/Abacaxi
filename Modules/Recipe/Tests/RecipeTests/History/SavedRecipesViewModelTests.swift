import DomainInterfaces
import Testing
@testable import Recipe

@MainActor
struct SavedRecipesViewModelTests {
    @Test func load_whenRecipesExist_exposesContentState() {
        let useCase = GetSavedRecipesUseCaseStub()
        useCase.stubbedResult = .success([recipe])
        let sut = SavedRecipesViewModel(getSavedRecipesUseCase: useCase)

        sut.load()

        #expect(sut.state == .content([SavedRecipePresentationModel(recipe)]))
    }

    @Test func load_whenHistoryIsEmpty_exposesEmptyState() {
        let sut = SavedRecipesViewModel(getSavedRecipesUseCase: GetSavedRecipesUseCaseStub())

        sut.load()

        #expect(sut.state == .empty)
    }

    @Test func load_whenQueryFails_exposesErrorState() {
        let useCase = GetSavedRecipesUseCaseStub()
        useCase.stubbedResult = .failure(GetSavedRecipesError.persistenceFailed)
        let sut = SavedRecipesViewModel(getSavedRecipesUseCase: useCase)

        sut.load()

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
