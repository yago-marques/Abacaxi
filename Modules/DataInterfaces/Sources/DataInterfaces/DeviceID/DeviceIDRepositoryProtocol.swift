import Foundation

public protocol DeviceIDRepositoryProtocol {
    func save(_ id: UUID) throws
    func load() throws -> UUID?
}
