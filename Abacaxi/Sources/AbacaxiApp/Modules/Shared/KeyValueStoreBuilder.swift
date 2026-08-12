import Persistence
import PersistenceInterfaces

enum KeyValueStoreBuilder {
    static func make() -> KeyValueStoringProtocol {
        keyValueStore
    }

    private static let keyValueStore: KeyValueStoringProtocol = UserDefaultsStore()
}
