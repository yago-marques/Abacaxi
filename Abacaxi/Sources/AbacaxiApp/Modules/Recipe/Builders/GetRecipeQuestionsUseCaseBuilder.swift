import Data
import Domain
import DomainInterfaces

enum GetRecipeQuestionsUseCaseBuilder {
    static func make() -> GetRecipeQuestionsUseCaseProtocol {
        let deviceIDRepository = DeviceIDRepositoryFactory.make(secureStoring: SecureStoreBuilder.make())
        let recipeQuestionsRepository = RecipeQuestionsRepositoryFactory.make(
            httpClient: NetworkClientBuilder.make(),
            apiKey: APIKeyBuilder.make()
        )
        return GetRecipeQuestionsUseCaseFactory.make(
            deviceIDRepository: deviceIDRepository,
            recipeQuestionsRepository: recipeQuestionsRepository
        )
    }
}
