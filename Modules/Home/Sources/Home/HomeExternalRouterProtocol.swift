import GeneralInterfaces

@MainActor
public protocol HomeExternalRouterProtocol {
    func openRecipeCreation(onFinish: @escaping () -> Void) -> CoordinatorProtocol
    func openSavedRecipes(onFinish: @escaping () -> Void) -> CoordinatorProtocol
}
