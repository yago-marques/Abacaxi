import DomainInterfaces

public protocol SavedRecipeRepositoryProtocol {
    func save(recipe: RecipeBusinessModel) async throws
    func fetchAll() async throws -> [SavedRecipeBusinessModel]
    func fetch(id: String) async throws -> RecipeBusinessModel?
    func remove(id: String) async throws
}

public enum SavedRecipeRepositoryError: Error, Equatable {
    case persistenceFailed
}
