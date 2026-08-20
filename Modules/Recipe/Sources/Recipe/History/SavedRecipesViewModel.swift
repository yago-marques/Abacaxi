import DomainInterfaces
import Foundation

enum SavedRecipesViewState: Equatable {
    case loading
    case empty
    case content([SavedRecipePresentationModel])
    case error
}

@MainActor
final class SavedRecipesViewModel: ObservableObject {
    private let getSavedRecipesUseCase: GetSavedRecipesUseCaseProtocol

    @Published private(set) var state: SavedRecipesViewState = .loading
    @Published var searchText = ""
    private(set) var loadTask: Task<Void, Never>?

    init(getSavedRecipesUseCase: GetSavedRecipesUseCaseProtocol) {
        self.getSavedRecipesUseCase = getSavedRecipesUseCase
    }

    deinit {
        loadTask?.cancel()
    }

    func load() {
        guard loadTask == nil else { return }

        state = .loading
        loadTask = Task { [weak self] in
            guard let self else { return }
            defer { loadTask = nil }

            do {
                let savedRecipes = try await getSavedRecipesUseCase.execute()
                let recipes = savedRecipes.map(SavedRecipePresentationModel.init)
                guard !Task.isCancelled else { return }
                state = recipes.isEmpty ? .empty : .content(recipes)
            } catch is CancellationError {
                // The view model is going away or the request was superseded.
            } catch {
                guard !Task.isCancelled else { return }
                state = .error
            }
        }
    }

    func filteredRecipes(from recipes: [SavedRecipePresentationModel]) -> [SavedRecipePresentationModel] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return recipes }

        return recipes.filter {
            $0.title.localizedCaseInsensitiveContains(query)
        }
    }
}
