import Data
import DataInterfaces
import Domain
import DomainInterfaces
import Persistence

enum SavedRecipesUseCaseBuilder {
    static func makeGet() -> GetSavedRecipesUseCaseProtocol {
        GetSavedRecipesUseCaseFactory.make(savedRecipeRepository: repository)
    }

    static func makeHas() -> HasSavedRecipesUseCaseProtocol {
        HasSavedRecipesUseCaseFactory.make(savedRecipeRepository: repository)
    }

    static func makeGetDetail() -> GetSavedRecipeUseCaseProtocol {
        GetSavedRecipeUseCaseFactory.make(savedRecipeRepository: repository)
    }

    static func makeRemove() -> RemoveSavedRecipeUseCaseProtocol {
        RemoveSavedRecipeUseCaseFactory.make(savedRecipeRepository: repository)
    }

    static let repository: SavedRecipeRepositoryProtocol = {
        let imageStore: RecipeImageStore
        do {
            imageStore = try RecipeImageStore()
        } catch {
            fatalError("Unable to create recipe image store: \(error)")
        }
        return SavedRecipeRepositoryFactory.make(
            persistentStore: SavedRecipeStoreBuilder.make(),
            imageStore: imageStore
        )
    }()
}
