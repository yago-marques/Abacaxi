import GeneralInterfaces

public protocol HomeExternalRouterProtocol {
    func openRecipeCreation() -> CoordinatorProtocol
    func openSavedRecipes() -> CoordinatorProtocol
}
