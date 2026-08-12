import Data
import Domain
import DomainInterfaces

enum GetDeviceIDUseCaseBuilder {
    static func make() -> GetDeviceIDUseCaseProtocol {
        let repository = DeviceIDRepositoryFactory.make(secureStoring: SecureStoreBuilder.make())
        return GetDeviceIDUseCaseFactory.make(repository: repository)
    }
}
