import DataInterfaces
import Foundation
import PersistenceInterfaces

public enum DeviceIDRepositoryFactory {
    public static func make(secureStoring: SecureStoringProtocol) -> DeviceIDRepositoryProtocol {
        DeviceIDRepository(secureStoring: secureStoring)
    }
}

public final class DeviceIDRepository: DeviceIDRepositoryProtocol {
    private static let storageKey = "device_id"

    private let secureStoring: SecureStoringProtocol

    public init(secureStoring: SecureStoringProtocol) {
        self.secureStoring = secureStoring
    }

    public func save(_ id: UUID) throws {
        try secureStoring.save(Data(id.uuidString.utf8), forKey: Self.storageKey)
    }

    public func load() throws -> UUID? {
        guard let data = try secureStoring.read(forKey: Self.storageKey),
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return UUID(uuidString: string)
    }
}
