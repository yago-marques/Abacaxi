import DataInterfaces
import Foundation

final class AttemptsRepositoryStub: AttemptsRepositoryProtocol {
    var stubbedResult: Result<AttemptsResponse, Error>?
    private(set) var receivedDeviceIDs: [UUID] = []

    func fetchAttempts(deviceID: UUID) async throws -> AttemptsResponse {
        receivedDeviceIDs.append(deviceID)
        guard let stubbedResult else {
            fatalError("Configure stubbedResult before fetching attempts.")
        }
        return try stubbedResult.get()
    }
}
