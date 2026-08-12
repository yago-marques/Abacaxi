import Foundation
@testable import DataInterfaces

final class DeviceIDRepositoryStub: DeviceIDRepositoryProtocol {
    private var storedID: UUID?

    func save(_ id: UUID) throws {
        storedID = id
    }

    func load() throws -> UUID? {
        storedID
    }
}
