import DomainInterfaces

public struct HomeViewState: Equatable {
    public let title: String
    public let dailyAttemptsText: String
    public let recipeCreationCardTitle: String
    public let recipeCreationCardSubtitle: String

    public init(
        title: String,
        dailyAttemptsText: String,
        recipeCreationCardTitle: String,
        recipeCreationCardSubtitle: String
    ) {
        self.title = title
        self.dailyAttemptsText = dailyAttemptsText
        self.recipeCreationCardTitle = recipeCreationCardTitle
        self.recipeCreationCardSubtitle = recipeCreationCardSubtitle
    }
}

public protocol HomeViewModelProtocol: AnyObject {
    var state: HomeViewState { get }
    func load() async
}

public final class HomeViewModel: HomeViewModelProtocol {
    private let getRemainingAttemptsUseCase: GetRemainingAttemptsUseCaseProtocol

    public private(set) var state: HomeViewState

    public init(getRemainingAttemptsUseCase: GetRemainingAttemptsUseCaseProtocol) {
        self.getRemainingAttemptsUseCase = getRemainingAttemptsUseCase
        state = HomeViewState(
            title: L10n.Home.title,
            dailyAttemptsText: L10n.Home.DailyAttempts.loading,
            recipeCreationCardTitle: L10n.Home.RecipeCreationCard.title,
            recipeCreationCardSubtitle: L10n.Home.RecipeCreationCard.subtitle
        )
    }

    public func load() async {
        do {
            let attempts = try await getRemainingAttemptsUseCase.execute()
            state = HomeViewState(
                title: state.title,
                dailyAttemptsText: L10n.Home.dailyAttempts(attempts.remaining),
                recipeCreationCardTitle: state.recipeCreationCardTitle,
                recipeCreationCardSubtitle: state.recipeCreationCardSubtitle
            )
        } catch {
            state = HomeViewState(
                title: state.title,
                dailyAttemptsText: L10n.Home.DailyAttempts.unavailable,
                recipeCreationCardTitle: state.recipeCreationCardTitle,
                recipeCreationCardSubtitle: state.recipeCreationCardSubtitle
            )
        }
    }
}
