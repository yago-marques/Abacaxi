import DomainInterfaces

final class GetSavedRecipesUseCaseStub: GetSavedRecipesUseCaseProtocol {
    var stubbedResult: Result<[SavedRecipeBusinessModel], Error> = .success([])
    private(set) var executeCount = 0

    func execute() async throws -> [SavedRecipeBusinessModel] {
        executeCount += 1
        return try stubbedResult.get()
    }
}

final class GetSavedRecipeUseCaseStub: GetSavedRecipeUseCaseProtocol {
    var stubbedResult: Result<RecipeBusinessModel?, Error> = .success(nil)
    private(set) var receivedIDs: [String] = []

    func execute(id: String) async throws -> RecipeBusinessModel? {
        receivedIDs.append(id)
        return try stubbedResult.get()
    }
}

final class RemoveSavedRecipeUseCaseStub: RemoveSavedRecipeUseCaseProtocol {
    var stubbedResult: Result<Void, Error> = .success(())
    private(set) var receivedIDs: [String] = []

    func execute(id: String) async throws {
        receivedIDs.append(id)
        try stubbedResult.get()
    }
}
