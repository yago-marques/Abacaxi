import GeneralInterfaces
import Home
import DomainInterfaces
import UIKit

enum HomeModule {
    static func registerDependencies(in container: UseCaseContainer) {
        container.register(ShouldShowOnboardingUseCaseProtocol.self) {
            ShouldShowOnboardingUseCaseBuilder.make()
        }
        container.register(CompleteOnboardingUseCaseProtocol.self) {
            CompleteOnboardingUseCaseBuilder.make()
        }
        container.register(GetRemainingAttemptsUseCaseProtocol.self) {
            GetRemainingAttemptsUseCaseBuilder.make()
        }
    }

    static func makeCoordinator(
        navigationController: UINavigationController,
        parent: CoordinatorProtocol,
        useCaseContainer: UseCaseContainer
    ) -> CoordinatorProtocol {
        let coordinator = HomeCoordinator(
            navigationController: navigationController,
            useCaseContainer: useCaseContainer
        )
        coordinator.parentCoordinator = parent
        return coordinator
    }
}
