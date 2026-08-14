import DomainInterfaces

public protocol SavedRecipeRepositoryProtocol {
    func save(recipe: RecipeBusinessModel) throws
    func fetchAll() throws -> [SavedRecipeBusinessModel]
    func fetch(id: String) throws -> RecipeBusinessModel?
    func remove(id: String) throws
}

public enum SavedRecipeRepositoryError: Error, Equatable {
    case persistenceFailed
}
