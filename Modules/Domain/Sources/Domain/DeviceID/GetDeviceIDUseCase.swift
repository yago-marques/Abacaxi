import DataInterfaces
import DomainInterfaces
import Foundation

public enum GetDeviceIDUseCaseFactory {
    public static func make(repository: DeviceIDRepositoryProtocol) -> GetDeviceIDUseCaseProtocol {
        GetDeviceIDUseCase(repository: repository)
    }
}

public final class GetDeviceIDUseCase: GetDeviceIDUseCaseProtocol {
    private let repository: DeviceIDRepositoryProtocol

    public init(repository: DeviceIDRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() throws -> UUID? {
        try repository.load()
    }
}
