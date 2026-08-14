import DomainInterfaces
import GeneralInterfaces
import Recipe
import UIKit

enum RecipeModule {
    static func registerDependencies(in container: UseCaseContainer) {
        container.register(GetRecipeQuestionsUseCaseProtocol.self) {
            GetRecipeQuestionsUseCaseBuilder.make()
        }
        container.register(GenerateRecipeUseCaseProtocol.self) {
            GenerateRecipeUseCaseBuilder.make()
        }
        container.register(SaveRecipeUseCaseProtocol.self) {
            SaveRecipeUseCaseBuilder.make()
        }
        container.register(GetSavedRecipesUseCaseProtocol.self) { SavedRecipesUseCaseBuilder.makeGet() }
        container.register(HasSavedRecipesUseCaseProtocol.self) { SavedRecipesUseCaseBuilder.makeHas() }
        container.register(GetSavedRecipeUseCaseProtocol.self) {
            SavedRecipesUseCaseBuilder.makeGetDetail()
        }
        container.register(RemoveSavedRecipeUseCaseProtocol.self) {
            SavedRecipesUseCaseBuilder.makeRemove()
        }
    }

    @discardableResult
    static func start(
        navigationController: UINavigationController,
        entryPoint: RecipeModuleFactory.EntryPoint,
        useCaseContainer: UseCaseContainer
    ) -> CoordinatorProtocol {
        let coordinator = RecipeModuleFactory.makeCoordinator(
            navigationController: navigationController,
            entryPoint: entryPoint,
            getRecipeQuestionsUseCase: useCaseContainer.resolve(GetRecipeQuestionsUseCaseProtocol.self),
            generateRecipeUseCase: useCaseContainer.resolve(GenerateRecipeUseCaseProtocol.self),
            saveRecipeUseCase: useCaseContainer.resolve(SaveRecipeUseCaseProtocol.self),
            getSavedRecipesUseCase: useCaseContainer.resolve(GetSavedRecipesUseCaseProtocol.self),
            getSavedRecipeUseCase: useCaseContainer.resolve(GetSavedRecipeUseCaseProtocol.self),
            removeSavedRecipeUseCase: useCaseContainer.resolve(RemoveSavedRecipeUseCaseProtocol.self)
        )
        coordinator.start()
        return coordinator
    }
}
