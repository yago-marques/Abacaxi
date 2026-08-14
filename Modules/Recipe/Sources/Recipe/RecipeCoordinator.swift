import DomainInterfaces
import GeneralInterfaces
import UIKit

final class RecipeCoordinator: CoordinatorProtocol {
    let navigationController: UINavigationController
    private let entryPoint: RecipeModuleFactory.EntryPoint
    private let getRecipeQuestionsUseCase: GetRecipeQuestionsUseCaseProtocol
    private let generateRecipeUseCase: GenerateRecipeUseCaseProtocol
    private let saveRecipeUseCase: SaveRecipeUseCaseProtocol
    private let getSavedRecipesUseCase: GetSavedRecipesUseCaseProtocol
    private let getSavedRecipeUseCase: GetSavedRecipeUseCaseProtocol
    private let removeSavedRecipeUseCase: RemoveSavedRecipeUseCaseProtocol
    private let onFinish: () -> Void

    init(
        navigationController: UINavigationController,
        entryPoint: RecipeModuleFactory.EntryPoint,
        getRecipeQuestionsUseCase: GetRecipeQuestionsUseCaseProtocol,
        generateRecipeUseCase: GenerateRecipeUseCaseProtocol,
        saveRecipeUseCase: SaveRecipeUseCaseProtocol,
        getSavedRecipesUseCase: GetSavedRecipesUseCaseProtocol,
        getSavedRecipeUseCase: GetSavedRecipeUseCaseProtocol,
        removeSavedRecipeUseCase: RemoveSavedRecipeUseCaseProtocol,
        onFinish: @escaping () -> Void = {}
    ) {
        self.navigationController = navigationController
        self.entryPoint = entryPoint
        self.getRecipeQuestionsUseCase = getRecipeQuestionsUseCase
        self.generateRecipeUseCase = generateRecipeUseCase
        self.saveRecipeUseCase = saveRecipeUseCase
        self.getSavedRecipesUseCase = getSavedRecipesUseCase
        self.getSavedRecipeUseCase = getSavedRecipeUseCase
        self.removeSavedRecipeUseCase = removeSavedRecipeUseCase
        self.onFinish = onFinish
    }

    func start() {
        navigationController.setNavigationBarHidden(true, animated: true)
        let viewController = RecipeFactory.makeFlowViewController(
            entryPoint: entryPoint,
            getRecipeQuestionsUseCase: getRecipeQuestionsUseCase,
            generateRecipeUseCase: generateRecipeUseCase,
            saveRecipeUseCase: saveRecipeUseCase,
            getSavedRecipesUseCase: getSavedRecipesUseCase,
            getSavedRecipeUseCase: getSavedRecipeUseCase,
            removeSavedRecipeUseCase: removeSavedRecipeUseCase,
            onFinish: { [weak navigationController = navigationController] in
                navigationController?.popViewController(animated: true)
            },
            // Fires on both programmatic finish (after the pop above) and
            // interactive swipe-back, so the parent can release this coordinator.
            onDismiss: { [weak self] in
                self?.onFinish()
            }
        )
        navigationController.pushViewController(viewController, animated: true)
    }
}
