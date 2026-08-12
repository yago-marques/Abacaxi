import GeneralInterfaces
import DomainInterfaces

public protocol OnboardingViewModelProtocol {
    func start()
    func didTapStart()
}

public final class OnboardingViewModel: OnboardingViewModelProtocol {
    private let shouldShowOnboardingUseCase: ShouldShowOnboardingUseCaseProtocol
    private let completeOnboardingUseCase: CompleteOnboardingUseCaseProtocol
    private weak var coordinator: CoordinatorProtocol?

    public init(
        shouldShowOnboardingUseCase: ShouldShowOnboardingUseCaseProtocol,
        completeOnboardingUseCase: CompleteOnboardingUseCaseProtocol,
        coordinator: CoordinatorProtocol
    ) {
        self.shouldShowOnboardingUseCase = shouldShowOnboardingUseCase
        self.completeOnboardingUseCase = completeOnboardingUseCase
        self.coordinator = coordinator
    }

    public func start() {
        coordinator?.handle(shouldShowOnboardingUseCase.execute() ? HomeAction.openOnboarding : HomeAction.openHome)
    }

    public func didTapStart() {
        completeOnboardingUseCase.execute()
        coordinator?.handle(HomeAction.openHome)
    }
}
