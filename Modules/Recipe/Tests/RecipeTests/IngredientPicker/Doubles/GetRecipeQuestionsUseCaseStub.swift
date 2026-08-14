import DomainInterfaces

final class GetRecipeQuestionsUseCaseStub: GetRecipeQuestionsUseCaseProtocol {
    var stubbedResult: Result<[RecipeQuestionBusinessModel], Error>?
    private(set) var receivedIngredients: [[RecipeIngredientBusinessModel]] = []

    func execute(ingredients: [RecipeIngredientBusinessModel]) async throws -> [RecipeQuestionBusinessModel] {
        receivedIngredients.append(ingredients)
        guard let stubbedResult else {
            fatalError("Configure stubbedResult before executing the use case.")
        }
        return try stubbedResult.get()
    }
}
