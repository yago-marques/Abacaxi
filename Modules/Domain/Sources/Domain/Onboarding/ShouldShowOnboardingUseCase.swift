import DataInterfaces
import DomainInterfaces

public enum ShouldShowOnboardingUseCaseFactory {
    public static func make(repository: OnboardingRepositoryProtocol) -> ShouldShowOnboardingUseCaseProtocol {
        ShouldShowOnboardingUseCase(repository: repository)
    }
}

public final class ShouldShowOnboardingUseCase: ShouldShowOnboardingUseCaseProtocol {
    private let repository: OnboardingRepositoryProtocol

    public init(repository: OnboardingRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() -> Bool {
        !repository.hasCompletedOnboarding()
    }
}
