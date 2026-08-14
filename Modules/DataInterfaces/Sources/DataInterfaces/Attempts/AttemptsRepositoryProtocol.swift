import Foundation

public enum AttemptsRepositoryError: Error, Equatable {
    case invalidResponse
    case network
    case cancelled
}

public protocol AttemptsRepositoryProtocol {
    func fetchAttempts(deviceID: UUID) async throws -> AttemptsResponse
}
