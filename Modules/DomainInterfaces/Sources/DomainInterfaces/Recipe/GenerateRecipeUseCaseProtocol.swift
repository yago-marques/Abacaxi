public protocol GenerateRecipeUseCaseProtocol {
    func execute(
        ingredients: [RecipeIngredientBusinessModel],
        answers: [RecipeAnswerBusinessModel]
    ) async throws -> RecipeBusinessModel
}

public enum GenerateRecipeError: Error, Equatable {
    case missingDeviceID
    case invalidIngredientCount
    case invalidIngredients
    case rateLimited
    case temporarilyUnavailable
    case invalidResponse
}
