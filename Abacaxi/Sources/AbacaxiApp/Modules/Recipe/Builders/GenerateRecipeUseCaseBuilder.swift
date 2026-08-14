import Data
import Domain
import DomainInterfaces

enum GenerateRecipeUseCaseBuilder {
    static func make() -> GenerateRecipeUseCaseProtocol {
        let deviceIDRepository = DeviceIDRepositoryFactory.make(secureStoring: SecureStoreBuilder.make())
        let recipeRepository = RecipeRepositoryFactory.make(
            httpClient: NetworkClientBuilder.make(),
            apiKey: APIKeyBuilder.make()
        )
        return GenerateRecipeUseCaseFactory.make(
            deviceIDRepository: deviceIDRepository,
            recipeRepository: recipeRepository
        )
    }
}
