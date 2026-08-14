import DomainInterfaces

final class GenerateRecipeUseCaseStub: GenerateRecipeUseCaseProtocol {
    func execute(
        ingredients: [RecipeIngredientBusinessModel],
        answers: [RecipeAnswerBusinessModel]
    ) async throws -> RecipeBusinessModel {
        throw GenerateRecipeError.invalidResponse
    }
}
