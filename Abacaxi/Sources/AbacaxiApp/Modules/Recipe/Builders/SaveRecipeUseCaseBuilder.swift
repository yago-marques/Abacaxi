import Data
import Domain
import DomainInterfaces
import Persistence

enum SaveRecipeUseCaseBuilder {
    static func make() -> SaveRecipeUseCaseProtocol {
        return SaveRecipeUseCaseFactory.make(
            savedRecipeRepository: SavedRecipesUseCaseBuilder.repository
        )
    }
}
