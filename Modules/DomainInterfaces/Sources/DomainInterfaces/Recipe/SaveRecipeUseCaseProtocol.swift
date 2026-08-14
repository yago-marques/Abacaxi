public protocol SaveRecipeUseCaseProtocol {
    func execute(recipe: RecipeBusinessModel) throws
}

public enum SaveRecipeError: Error, Equatable {
    case persistenceFailed
}

public protocol RemoveSavedRecipeUseCaseProtocol {
    func execute(id: String) throws
}

public enum RemoveSavedRecipeError: Error, Equatable {
    case persistenceFailed
}
