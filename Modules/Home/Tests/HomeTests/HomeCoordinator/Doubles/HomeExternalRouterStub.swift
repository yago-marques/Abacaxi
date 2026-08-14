import GeneralInterfaces
@testable import Home

final class HomeExternalRouterStub: HomeExternalRouterProtocol {
    var stubbedCoordinator: CoordinatorProtocol?
    private(set) var openRecipeCreationCalled = false
    private(set) var openSavedRecipesCalled = false
    private(set) var lastOnFinish: (() -> Void)?

    func openRecipeCreation(onFinish: @escaping () -> Void) -> CoordinatorProtocol {
        openRecipeCreationCalled = true
        lastOnFinish = onFinish
        guard let stubbedCoordinator else {
            fatalError("stubbedCoordinator must be set before calling openRecipeCreation")
        }
        return stubbedCoordinator
    }

    func openSavedRecipes(onFinish: @escaping () -> Void) -> CoordinatorProtocol {
        openSavedRecipesCalled = true
        lastOnFinish = onFinish
        guard let stubbedCoordinator else {
            fatalError("stubbedCoordinator must be set before calling openSavedRecipes")
        }
        return stubbedCoordinator
    }
}
