import DataInterfaces
import DomainInterfaces
import Foundation

final class RecipeQuestionsRepositoryStub: RecipeQuestionsRepositoryProtocol {
    var stubbedResult: Result<[RecipeQuestionBusinessModel], Error>?
    private(set) var receivedDeviceIDs: [UUID] = []
    private(set) var receivedIngredients: [[RecipeIngredientBusinessModel]] = []

    func fetchQuestions(
        deviceID: UUID,
        ingredients: [RecipeIngredientBusinessModel]
    ) async throws -> [RecipeQuestionBusinessModel] {
        receivedDeviceIDs.append(deviceID)
        receivedIngredients.append(ingredients)
        guard let stubbedResult else {
            fatalError("Configure stubbedResult before fetching questions.")
        }
        return try stubbedResult.get()
    }
}
