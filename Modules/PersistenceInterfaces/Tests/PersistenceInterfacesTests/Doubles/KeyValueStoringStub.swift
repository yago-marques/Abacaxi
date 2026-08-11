@testable import PersistenceInterfaces

final class KeyValueStoringStub: KeyValueStoring {
    private var storage: [String: Any] = [:]

    func set<T>(_ value: T?, forKey key: String) {
        storage[key] = value
    }

    func value<T>(forKey key: String) -> T? {
        storage[key] as? T
    }

    func removeValue(forKey key: String) {
        storage.removeValue(forKey: key)
    }
}
