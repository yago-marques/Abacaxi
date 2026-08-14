import GeneralInterfaces
@testable import Home

final class HomeExternalRouterStub: HomeExternalRouterProtocol {
    var stubbedCoordinator: CoordinatorProtocol?
    private(set) var openRecipeCreationCalled = false
    private(set) var openSavedRecipesCalled = false

    func openRecipeCreation() -> CoordinatorProtocol {
        openRecipeCreationCalled = true
        return stubbedCoordinator!
    }

    func openSavedRecipes() -> CoordinatorProtocol {
        openSavedRecipesCalled = true
        return stubbedCoordinator!
    }
}
