public enum GetRecipeQuestionsError: Error, Equatable {
    case missingDeviceID
    case invalidIngredientCount
    case invalidIngredients
    case rateLimited
    case temporarilyUnavailable
    case invalidResponse
    case noConnection
    case cancelled
}
