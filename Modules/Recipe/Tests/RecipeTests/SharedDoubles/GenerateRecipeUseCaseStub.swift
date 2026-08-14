import DomainInterfaces
import Foundation

final class GenerateRecipeUseCaseStub: GenerateRecipeUseCaseProtocol {
    var stubbedResult: Result<RecipeBusinessModel, Error> = .success(
        RecipeBusinessModel(
            title: "Receita",
            description: "Descrição",
            ingredients: [],
            steps: [],
            preparationTimeMinutes: 20,
            servings: 2,
            nutrition: nil,
            imageData: nil
        )
    )
    var delayNanoseconds: UInt64?
    private(set) var receivedIngredients: [[RecipeIngredientBusinessModel]] = []
    private(set) var receivedAnswers: [[RecipeAnswerBusinessModel]] = []

    func execute(
        ingredients: [RecipeIngredientBusinessModel],
        answers: [RecipeAnswerBusinessModel]
    ) async throws -> RecipeBusinessModel {
        receivedIngredients.append(ingredients)
        receivedAnswers.append(answers)
        if let delayNanoseconds {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }
        return try stubbedResult.get()
    }
}
