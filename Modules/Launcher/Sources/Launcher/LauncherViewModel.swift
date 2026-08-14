import GeneralInterfaces
import DomainInterfaces

@MainActor
public protocol LauncherViewModelProtocol {
    func checkDeviceID()
}

@MainActor
public final class LauncherViewModel: LauncherViewModelProtocol {
    private let getDeviceIDUseCase: GetDeviceIDUseCaseProtocol
    private let createDeviceIDUseCase: CreateDeviceIDUseCaseProtocol

    private weak var coordinator: CoordinatorProtocol?

    public init(
        getDeviceIDUseCase: GetDeviceIDUseCaseProtocol,
        createDeviceIDUseCase: CreateDeviceIDUseCaseProtocol,
        coordinator: CoordinatorProtocol
    ) {
        self.getDeviceIDUseCase = getDeviceIDUseCase
        self.createDeviceIDUseCase = createDeviceIDUseCase
        self.coordinator = coordinator
    }

    public func checkDeviceID() {
        do {
            if try getDeviceIDUseCase.execute() == nil {
                try createDeviceIDUseCase.execute()
            }
        } catch {
            // Swallowed: DeviceID resolution must never block the Launcher → Home transition.
        }
        coordinator?.handle(LauncherAction.closeLauncher)
    }
}
