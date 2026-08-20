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
    @Published private(set) var isRemoving = false
    @Published private(set) var didRemove = false
    @Published private(set) var didFailRemoving = false

    private(set) var saveTask: Task<Void, Never>?
    private(set) var removeTask: Task<Void, Never>?

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

    deinit {
        saveTask?.cancel()
        removeTask?.cancel()
    }

    func save() {
        guard !isSaving, !isSaved else { return }

        isSaving = true
        didFailSaving = false
        saveTask = Task { [weak self, recipe] in
            guard let self else { return }
            defer {
                saveTask = nil
                isSaving = false
            }

            do {
                try await saveRecipeUseCase.execute(recipe: recipe)
                guard !Task.isCancelled else { return }
                isSaved = true
            } catch is CancellationError {
                // The view model is going away or the action was superseded.
            } catch {
                guard !Task.isCancelled else { return }
                didFailSaving = true
            }
        }
    }

    func remove(id: String) {
        guard !isRemoving else { return }

        isRemoving = true
        didRemove = false
        didFailRemoving = false
        removeTask = Task { [weak self] in
            guard let self else { return }
            defer {
                removeTask = nil
                isRemoving = false
            }

            do {
                try await removeSavedRecipeUseCase.execute(id: id)
                guard !Task.isCancelled else { return }
                didRemove = true
            } catch is CancellationError {
                // The view model is going away or the action was superseded.
            } catch {
                guard !Task.isCancelled else { return }
                didFailRemoving = true
            }
        }
    }
}
