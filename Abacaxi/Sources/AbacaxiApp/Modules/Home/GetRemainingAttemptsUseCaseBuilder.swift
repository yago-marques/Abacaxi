import Data
import Domain
import DomainInterfaces

enum GetRemainingAttemptsUseCaseBuilder {
    static func make() -> GetRemainingAttemptsUseCaseProtocol {
        let deviceIDRepository = DeviceIDRepositoryFactory.make(secureStoring: SecureStoreBuilder.make())
        let attemptsRepository = AttemptsRepositoryFactory.make(
            httpClient: NetworkClientBuilder.make(),
            apiKey: APIKeyBuilder.make()
        )
        return GetRemainingAttemptsUseCaseFactory.make(
            deviceIDRepository: deviceIDRepository,
            attemptsRepository: attemptsRepository
        )
    }
}
