public protocol GetRemainingAttemptsUseCaseProtocol {
    func execute() async throws -> RemainingAttempts
}
