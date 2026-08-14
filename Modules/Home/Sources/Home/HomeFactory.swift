import DomainInterfaces
import GeneralInterfaces
import UIKit

enum HomeFactory {
    static func makeViewController(
        useCaseContainer: UseCaseContainer,
        coordinator: CoordinatorProtocol
    ) -> HomeViewController {
        let viewModel = HomeViewModel(
            getRemainingAttemptsUseCase: useCaseContainer.resolve(GetRemainingAttemptsUseCaseProtocol.self),
            hasSavedRecipesUseCase: useCaseContainer.resolve(HasSavedRecipesUseCaseProtocol.self),
            coordinator: coordinator
        )
        return HomeViewController(viewModel: viewModel)
    }
}
