import Foundation
import PersistenceInterfaces

public final class UserDefaultsStore: KeyValueStoringProtocol {
    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func set<T>(_ value: T?, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    public func value<T>(forKey key: String) -> T? {
        defaults.object(forKey: key) as? T
    }

    public func removeValue(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
}
