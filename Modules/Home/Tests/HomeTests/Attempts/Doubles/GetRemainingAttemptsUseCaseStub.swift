import DomainInterfaces

final class GetRemainingAttemptsUseCaseStub: GetRemainingAttemptsUseCaseProtocol {
    var stubbedResult: Result<RemainingAttempts, Error> = .success(
        RemainingAttempts(remaining: 0, limit: 20, windowSeconds: 3_600)
    )

    func execute() async throws -> RemainingAttempts {
        try stubbedResult.get()
    }
}
