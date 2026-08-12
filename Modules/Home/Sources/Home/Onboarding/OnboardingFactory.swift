import GeneralInterfaces
import DomainInterfaces
import UIKit

public enum OnboardingFactory {
    public static func makeViewController(
        useCaseContainer: UseCaseContainer,
        coordinator: CoordinatorProtocol
    ) -> UIViewController {
        let shouldShowOnboardingUseCase = useCaseContainer.resolve(ShouldShowOnboardingUseCaseProtocol.self)
        let completeOnboardingUseCase = useCaseContainer.resolve(CompleteOnboardingUseCaseProtocol.self)
        let viewModel = OnboardingViewModel(
            shouldShowOnboardingUseCase: shouldShowOnboardingUseCase,
            completeOnboardingUseCase: completeOnboardingUseCase,
            coordinator: coordinator
        )
        return OnboardingViewController(viewModel: viewModel)
    }
}
