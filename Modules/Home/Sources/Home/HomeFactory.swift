import DomainInterfaces
import GeneralInterfaces
import UIKit

public enum HomeFactory {
    public static func makeViewController(useCaseContainer: UseCaseContainer) -> HomeViewController {
        let viewModel = HomeViewModel(
            getRemainingAttemptsUseCase: useCaseContainer.resolve(GetRemainingAttemptsUseCaseProtocol.self)
        )
        return HomeViewController(viewModel: viewModel)
    }
}
