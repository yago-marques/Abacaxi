import Persistence
import PersistenceInterfaces

enum SecureStoreBuilder {
    static func make() -> SecureStoringProtocol {
        secureStore
    }

    private static let secureStore: SecureStoringProtocol = {
        guard let secureStore = try? KeychainStore() else {
            fatalError("Failed to initialize KeychainStore: missing bundle identifier")
        }
        return secureStore
    }()
}
