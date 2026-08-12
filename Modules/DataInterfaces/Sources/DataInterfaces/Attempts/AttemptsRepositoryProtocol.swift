import Foundation

public protocol AttemptsRepositoryProtocol {
    func fetchAttempts(deviceID: UUID) async throws -> AttemptsResponse
}
