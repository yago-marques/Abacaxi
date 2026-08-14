public protocol GetRecipeQuestionsUseCaseProtocol {
    func execute(ingredients: [RecipeIngredientBusinessModel]) async throws -> [RecipeQuestionBusinessModel]
}
