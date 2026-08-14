import DomainInterfaces
import Foundation

enum SavedRecipesViewState: Equatable {
    case loading
    case empty
    case content([SavedRecipePresentationModel])
    case error
}

final class SavedRecipesViewModel: ObservableObject {
    private let getSavedRecipesUseCase: GetSavedRecipesUseCaseProtocol

    @Published private(set) var state: SavedRecipesViewState = .loading
    @Published var searchText = ""

    init(getSavedRecipesUseCase: GetSavedRecipesUseCaseProtocol) {
        self.getSavedRecipesUseCase = getSavedRecipesUseCase
    }

    func load() {
        do {
            let recipes = try getSavedRecipesUseCase.execute().map(SavedRecipePresentationModel.init)
            state = recipes.isEmpty ? .empty : .content(recipes)
        } catch {
            state = .error
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
