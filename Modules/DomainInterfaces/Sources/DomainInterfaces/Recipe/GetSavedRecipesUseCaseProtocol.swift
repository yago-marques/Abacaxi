public protocol GetSavedRecipesUseCaseProtocol {
    func execute() throws -> [SavedRecipeBusinessModel]
}

public protocol HasSavedRecipesUseCaseProtocol {
    func execute() throws -> Bool
}

public protocol GetSavedRecipeUseCaseProtocol {
    func execute(id: String) throws -> RecipeBusinessModel?
}

public enum GetSavedRecipesError: Error, Equatable {
    case persistenceFailed
}
