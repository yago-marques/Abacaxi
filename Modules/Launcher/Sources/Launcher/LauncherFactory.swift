import DomainInterfaces
import GeneralInterfaces
import UIKit

public enum LauncherFactory {
    @MainActor
    public static func makeViewController(
        useCaseContainer: UseCaseContainer,
        coordinator: CoordinatorProtocol
    ) -> LauncherViewController {
        let getDeviceIDUseCase = useCaseContainer.resolve(GetDeviceIDUseCaseProtocol.self)
        let createDeviceIDUseCase = useCaseContainer.resolve(CreateDeviceIDUseCaseProtocol.self)
        let viewModel = LauncherViewModel(
            getDeviceIDUseCase: getDeviceIDUseCase,
            createDeviceIDUseCase: createDeviceIDUseCase,
            coordinator: coordinator
        )
        return LauncherViewController(viewModel: viewModel)
    }
}
