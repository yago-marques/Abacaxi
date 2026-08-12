import DataInterfaces
import DomainInterfaces

public enum CompleteOnboardingUseCaseFactory {
    public static func make(repository: OnboardingRepositoryProtocol) -> CompleteOnboardingUseCaseProtocol {
        CompleteOnboardingUseCase(repository: repository)
    }
}

public final class CompleteOnboardingUseCase: CompleteOnboardingUseCaseProtocol {
    private let repository: OnboardingRepositoryProtocol

    public init(repository: OnboardingRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() {
        repository.completeOnboarding()
    }
}
