import Data
import Domain
import DomainInterfaces

enum ShouldShowOnboardingUseCaseBuilder {
    static func make() -> ShouldShowOnboardingUseCaseProtocol {
        let repository = OnboardingRepositoryFactory.make(keyValueStore: KeyValueStoreBuilder.make())
        return ShouldShowOnboardingUseCaseFactory.make(repository: repository)
    }
}
