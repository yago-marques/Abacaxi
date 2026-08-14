import DomainInterfaces
import GeneralInterfaces

struct HomeViewState: Equatable {
    let title: String
    let dailyAttemptsText: String
    let recipeCreationCardTitle: String
    let recipeCreationCardSubtitle: String
    let savedRecipesCardTitle: String
    let savedRecipesCardSubtitle: String
    let showsSavedRecipesShortcut: Bool

    init(
        title: String,
        dailyAttemptsText: String,
        recipeCreationCardTitle: String,
        recipeCreationCardSubtitle: String,
        savedRecipesCardTitle: String,
        savedRecipesCardSubtitle: String,
        showsSavedRecipesShortcut: Bool
    ) {
        self.title = title
        self.dailyAttemptsText = dailyAttemptsText
        self.recipeCreationCardTitle = recipeCreationCardTitle
        self.recipeCreationCardSubtitle = recipeCreationCardSubtitle
        self.savedRecipesCardTitle = savedRecipesCardTitle
        self.savedRecipesCardSubtitle = savedRecipesCardSubtitle
        self.showsSavedRecipesShortcut = showsSavedRecipesShortcut
    }
}

protocol HomeViewModelProtocol: AnyObject {
    var state: HomeViewState { get }
    func load() async
    func didTapRecipeCreation()
    func didTapSavedRecipes()
}

final class HomeViewModel: HomeViewModelProtocol {
    private let getRemainingAttemptsUseCase: GetRemainingAttemptsUseCaseProtocol
    private let hasSavedRecipesUseCase: HasSavedRecipesUseCaseProtocol
    private weak var coordinator: CoordinatorProtocol?

    private(set) var state: HomeViewState

    init(
        getRemainingAttemptsUseCase: GetRemainingAttemptsUseCaseProtocol,
        hasSavedRecipesUseCase: HasSavedRecipesUseCaseProtocol,
        coordinator: CoordinatorProtocol? = nil
    ) {
        self.getRemainingAttemptsUseCase = getRemainingAttemptsUseCase
        self.hasSavedRecipesUseCase = hasSavedRecipesUseCase
        self.coordinator = coordinator
        state = HomeViewState(
            title: L10n.Home.title,
            dailyAttemptsText: L10n.Home.DailyAttempts.loading,
            recipeCreationCardTitle: L10n.Home.RecipeCreationCard.title,
            recipeCreationCardSubtitle: L10n.Home.RecipeCreationCard.subtitle,
            savedRecipesCardTitle: L10n.Home.SavedRecipesCard.title,
            savedRecipesCardSubtitle: L10n.Home.SavedRecipesCard.subtitle,
            showsSavedRecipesShortcut: false
        )
    }

    func load() async {
        let showsSavedRecipes = (try? hasSavedRecipesUseCase.execute()) ?? false
        do {
            let attempts = try await getRemainingAttemptsUseCase.execute()
            state = HomeViewState(
                title: state.title,
                dailyAttemptsText: L10n.Home.dailyAttempts(attempts.remaining),
                recipeCreationCardTitle: state.recipeCreationCardTitle,
                recipeCreationCardSubtitle: state.recipeCreationCardSubtitle,
                savedRecipesCardTitle: state.savedRecipesCardTitle,
                savedRecipesCardSubtitle: state.savedRecipesCardSubtitle,
                showsSavedRecipesShortcut: showsSavedRecipes
            )
        } catch {
            state = HomeViewState(
                title: state.title,
                dailyAttemptsText: L10n.Home.DailyAttempts.unavailable,
                recipeCreationCardTitle: state.recipeCreationCardTitle,
                recipeCreationCardSubtitle: state.recipeCreationCardSubtitle,
                savedRecipesCardTitle: state.savedRecipesCardTitle,
                savedRecipesCardSubtitle: state.savedRecipesCardSubtitle,
                showsSavedRecipesShortcut: showsSavedRecipes
            )
        }
    }

    func didTapRecipeCreation() {
        coordinator?.handle(HomeAction.openRecipeCreation)
    }

    func didTapSavedRecipes() { coordinator?.handle(HomeAction.openSavedRecipes) }
}
