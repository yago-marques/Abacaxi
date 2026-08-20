public protocol GetSavedRecipesUseCaseProtocol {
    func execute() async throws -> [SavedRecipeBusinessModel]
}

public protocol HasSavedRecipesUseCaseProtocol {
    func execute() async throws -> Bool
}

public protocol GetSavedRecipeUseCaseProtocol {
    func execute(id: String) async throws -> RecipeBusinessModel?
}

public enum GetSavedRecipesError: Error, Equatable {
    case persistenceFailed
}
