import DomainInterfaces

final class HasSavedRecipesUseCaseStub: HasSavedRecipesUseCaseProtocol {
    var stubbedResult: Result<Bool, Error> = .success(false)

    func execute() async throws -> Bool {
        try stubbedResult.get()
    }
}
