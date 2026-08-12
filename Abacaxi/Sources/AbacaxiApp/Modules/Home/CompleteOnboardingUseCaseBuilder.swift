import Data
import Domain
import DomainInterfaces

enum CompleteOnboardingUseCaseBuilder {
    static func make() -> CompleteOnboardingUseCaseProtocol {
        let repository = OnboardingRepositoryFactory.make(keyValueStore: KeyValueStoreBuilder.make())
        return CompleteOnboardingUseCaseFactory.make(repository: repository)
    }
}
