import Foundation
@testable import PersistenceInterfaces

final class SecureStoringStub: SecureStoringProtocol {
    private var storage: [String: Data] = [:]

    func save(_ data: Data, forKey key: String) throws {
        storage[key] = data
    }

    func read(forKey key: String) throws -> Data? {
        storage[key]
    }

    func delete(forKey key: String) throws {
        storage.removeValue(forKey: key)
    }
}
