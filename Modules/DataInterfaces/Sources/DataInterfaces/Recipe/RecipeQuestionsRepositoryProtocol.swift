import DomainInterfaces
import Foundation

public enum RecipeQuestionsRepositoryError: Error, Equatable {
    case invalidIngredients
    case rateLimited
    case temporarilyUnavailable
    case invalidResponse
    case network
    case cancelled
}

public protocol RecipeQuestionsRepositoryProtocol {
    func fetchQuestions(
        deviceID: UUID,
        ingredients: [RecipeIngredientBusinessModel]
    ) async throws -> [RecipeQuestionBusinessModel]
}
