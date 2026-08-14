import DomainInterfaces

final class SaveRecipeUseCaseSpy: SaveRecipeUseCaseProtocol {
    private(set) var receivedRecipes: [RecipeBusinessModel] = []

    func execute(recipe: RecipeBusinessModel) throws {
        receivedRecipes.append(recipe)
    }
}
