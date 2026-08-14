import GeneralInterfaces
import Home
import DomainInterfaces
import Recipe
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

    @MainActor
    @discardableResult
    static func start(
        navigationController: UINavigationController,
        useCaseContainer: UseCaseContainer
    ) -> CoordinatorProtocol {
        let coordinator = HomeModuleFactory.makeCoordinator(
            navigationController: navigationController,
            useCaseContainer: useCaseContainer,
            externalRouter: HomeExternalRouter(
                navigationController: navigationController,
                useCaseContainer: useCaseContainer
            )
        )
        coordinator.start()
        return coordinator
    }
}
