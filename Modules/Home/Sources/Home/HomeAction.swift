import GeneralInterfaces

enum HomeAction: CoordinatorActionProtocol, Equatable {
    case openHome
    case openOnboarding
    case openRecipeCreation
    case openSavedRecipes
}
