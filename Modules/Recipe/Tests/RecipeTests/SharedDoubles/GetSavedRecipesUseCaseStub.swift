import DomainInterfaces

final class GetSavedRecipesUseCaseStub: GetSavedRecipesUseCaseProtocol {
    var stubbedResult: Result<[SavedRecipeBusinessModel], Error> = .success([])

    func execute() throws -> [SavedRecipeBusinessModel] {
        try stubbedResult.get()
    }
}

final class GetSavedRecipeUseCaseStub: GetSavedRecipeUseCaseProtocol {
    var stubbedResult: Result<RecipeBusinessModel?, Error> = .success(nil)

    func execute(id: String) throws -> RecipeBusinessModel? {
        try stubbedResult.get()
    }
}

final class RemoveSavedRecipeUseCaseStub: RemoveSavedRecipeUseCaseProtocol {
    var stubbedResult: Result<Void, Error> = .success(())
    private(set) var receivedIDs: [String] = []

    func execute(id: String) throws {
        receivedIDs.append(id)
        try stubbedResult.get()
    }
}
