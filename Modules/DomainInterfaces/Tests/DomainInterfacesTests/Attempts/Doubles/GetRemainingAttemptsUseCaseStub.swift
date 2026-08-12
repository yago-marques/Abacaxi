import DomainInterfaces

final class GetRemainingAttemptsUseCaseStub: GetRemainingAttemptsUseCaseProtocol {
    var stubbedResult: Result<RemainingAttempts, Error>?

    func execute() async throws -> RemainingAttempts {
        guard let stubbedResult else {
            fatalError("Configure stubbedResult before executing the use case.")
        }
        return try stubbedResult.get()
    }
}
