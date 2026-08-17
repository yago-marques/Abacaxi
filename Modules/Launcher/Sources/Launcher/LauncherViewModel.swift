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
        try? createDeviceIDIfMissing()
        coordinator?.handle(LauncherAction.closeLauncher)
    }

    private func createDeviceIDIfMissing() throws {
        if try getDeviceIDUseCase.execute() == nil {
            try createDeviceIDUseCase.execute()
        }
    }
}
