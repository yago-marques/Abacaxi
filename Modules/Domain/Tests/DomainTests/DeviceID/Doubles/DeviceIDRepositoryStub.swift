import DataInterfaces
import Foundation

final class DeviceIDRepositoryStub: DeviceIDRepositoryProtocol {
    private(set) var savedIDs: [UUID] = []
    var stubbedLoadResult: UUID?

    func save(_ id: UUID) throws {
        savedIDs.append(id)
    }

    func load() throws -> UUID? {
        stubbedLoadResult
    }
}
