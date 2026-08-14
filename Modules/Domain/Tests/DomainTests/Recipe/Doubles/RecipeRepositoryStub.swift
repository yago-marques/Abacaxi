import DataInterfaces
import DomainInterfaces
import Foundation

final class RecipeRepositoryStub: RecipeRepositoryProtocol {
    var stubbedResult: Result<RecipeBusinessModel, Error>?
    private(set) var receivedDeviceIDs: [UUID] = []
    private(set) var receivedIngredients: [[RecipeIngredientBusinessModel]] = []
    private(set) var receivedAnswers: [[RecipeAnswerBusinessModel]] = []

    func fetchRecipe(
        deviceID: UUID,
        ingredients: [RecipeIngredientBusinessModel],
        answers: [RecipeAnswerBusinessModel]
    ) async throws -> RecipeBusinessModel {
        receivedDeviceIDs.append(deviceID)
        receivedIngredients.append(ingredients)
        receivedAnswers.append(answers)
        guard let stubbedResult else {
            fatalError("Configure stubbedResult before fetching a recipe.")
        }
        return try stubbedResult.get()
    }
}
