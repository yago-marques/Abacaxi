import Data
import Domain
import DomainInterfaces

enum CreateDeviceIDUseCaseBuilder {
    static func make() -> CreateDeviceIDUseCaseProtocol {
        let repository = DeviceIDRepositoryFactory.make(secureStoring: SecureStoreBuilder.make())
        return CreateDeviceIDUseCaseFactory.make(repository: repository)
    }
}
