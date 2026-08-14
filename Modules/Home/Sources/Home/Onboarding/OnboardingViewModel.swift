import GeneralInterfaces
import DomainInterfaces

@MainActor
protocol OnboardingViewModelProtocol {
    func start()
    func didTapStart()
}

@MainActor
final class OnboardingViewModel: OnboardingViewModelProtocol {
    private let shouldShowOnboardingUseCase: ShouldShowOnboardingUseCaseProtocol
    private let completeOnboardingUseCase: CompleteOnboardingUseCaseProtocol
    private weak var coordinator: CoordinatorProtocol?

    init(
        shouldShowOnboardingUseCase: ShouldShowOnboardingUseCaseProtocol,
        completeOnboardingUseCase: CompleteOnboardingUseCaseProtocol,
        coordinator: CoordinatorProtocol
    ) {
        self.shouldShowOnboardingUseCase = shouldShowOnboardingUseCase
        self.completeOnboardingUseCase = completeOnboardingUseCase
        self.coordinator = coordinator
    }

    func start() {
        coordinator?.handle(shouldShowOnboardingUseCase.execute() ? HomeAction.openOnboarding : HomeAction.openHome)
    }

    func didTapStart() {
        completeOnboardingUseCase.execute()
        coordinator?.handle(HomeAction.openHome)
    }
}
