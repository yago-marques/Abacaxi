import DataInterfaces
import PersistenceInterfaces

public enum OnboardingRepositoryFactory {
    public static func make(keyValueStore: KeyValueStoringProtocol) -> OnboardingRepositoryProtocol {
        OnboardingRepository(keyValueStore: keyValueStore)
    }
}

public final class OnboardingRepository: OnboardingRepositoryProtocol {
    private enum StorageKey {
        static let hasCompletedOnboarding = "home.hasCompletedOnboarding"
    }

    private let keyValueStore: KeyValueStoringProtocol

    public init(keyValueStore: KeyValueStoringProtocol) {
        self.keyValueStore = keyValueStore
    }

    public func hasCompletedOnboarding() -> Bool {
        keyValueStore.value(forKey: StorageKey.hasCompletedOnboarding) ?? false
    }

    public func completeOnboarding() {
        keyValueStore.set(true, forKey: StorageKey.hasCompletedOnboarding)
    }
}
