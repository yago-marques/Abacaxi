import Combine
import DomainInterfaces

@MainActor
final class RecipeResultViewModel: ObservableObject {
    private let recipe: RecipeBusinessModel
    private let saveRecipeUseCase: SaveRecipeUseCaseProtocol
    private let removeSavedRecipeUseCase: RemoveSavedRecipeUseCaseProtocol

    @Published private(set) var isSaving = false
    @Published private(set) var isSaved = false
    @Published private(set) var didFailSaving = false

    init(
        recipe: RecipeBusinessModel,
        saveRecipeUseCase: SaveRecipeUseCaseProtocol,
        removeSavedRecipeUseCase: RemoveSavedRecipeUseCaseProtocol
    ) {
        self.recipe = recipe
        self.saveRecipeUseCase = saveRecipeUseCase
        self.removeSavedRecipeUseCase = removeSavedRecipeUseCase
    }

    var saveTitle: String {
        if isSaved {
            return L10n.RecipeResult.saved
        }
        return isSaving ? L10n.RecipeResult.saving : L10n.RecipeResult.save
    }

    func save() {
        guard !isSaving, !isSaved else { return }

        isSaving = true
        didFailSaving = false
        do {
            try saveRecipeUseCase.execute(recipe: recipe)
            isSaved = true
        } catch {
            didFailSaving = true
        }
        isSaving = false
    }

    func remove(id: String) -> Bool {
        do {
            try removeSavedRecipeUseCase.execute(id: id)
            return true
        } catch {
            return false
        }
    }
}
