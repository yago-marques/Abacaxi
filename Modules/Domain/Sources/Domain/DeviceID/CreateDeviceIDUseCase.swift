import DataInterfaces
import DomainInterfaces
import Foundation

public enum CreateDeviceIDUseCaseFactory {
    public static func make(repository: DeviceIDRepositoryProtocol) -> CreateDeviceIDUseCaseProtocol {
        CreateDeviceIDUseCase(repository: repository)
    }
}

public final class CreateDeviceIDUseCase: CreateDeviceIDUseCaseProtocol {
    private let repository: DeviceIDRepositoryProtocol

    public init(repository: DeviceIDRepositoryProtocol) {
        self.repository = repository
    }

    @discardableResult
    public func execute() throws -> UUID {
        let id = UUID()
        try repository.save(id)
        return id
    }
}
