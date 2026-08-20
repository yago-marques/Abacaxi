public protocol SaveRecipeUseCaseProtocol {
    func execute(recipe: RecipeBusinessModel) async throws
}

public enum SaveRecipeError: Error, Equatable {
    case persistenceFailed
}

public protocol RemoveSavedRecipeUseCaseProtocol {
    func execute(id: String) async throws
}

public enum RemoveSavedRecipeError: Error, Equatable {
    case persistenceFailed
}
