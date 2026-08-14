import DomainInterfaces

final class SaveRecipeUseCaseSpy: SaveRecipeUseCaseProtocol {
    var stubbedResult: Result<Void, Error> = .success(())
    private(set) var receivedRecipes: [RecipeBusinessModel] = []

    func execute(recipe: RecipeBusinessModel) throws {
        receivedRecipes.append(recipe)
        try stubbedResult.get()
    }
}
