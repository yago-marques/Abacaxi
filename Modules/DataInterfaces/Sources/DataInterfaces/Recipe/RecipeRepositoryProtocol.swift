import DomainInterfaces
import Foundation

public protocol RecipeRepositoryProtocol {
    func fetchRecipe(
        deviceID: UUID,
        ingredients: [RecipeIngredientBusinessModel],
        answers: [RecipeAnswerBusinessModel]
    ) async throws -> RecipeBusinessModel
}

public enum RecipeRepositoryError: Error, Equatable {
    case invalidIngredients
    case rateLimited
    case temporarilyUnavailable
    case invalidResponse
}
