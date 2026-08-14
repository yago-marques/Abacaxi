import DesignSystem
import DomainInterfaces
import SwiftUI

struct RecipeFlowView: View {
    @StateObject private var viewModel: RecipeFlowViewModel

    private let getRecipeQuestionsUseCase: GetRecipeQuestionsUseCaseProtocol
    private let saveRecipeUseCase: SaveRecipeUseCaseProtocol
    private let getSavedRecipesUseCase: GetSavedRecipesUseCaseProtocol
    private let removeSavedRecipeUseCase: RemoveSavedRecipeUseCaseProtocol
    private let onDismiss: () -> Void
    @State private var toastRequest: DSToastRequest?

    init(
        entryPoint: RecipeModuleFactory.EntryPoint,
        getRecipeQuestionsUseCase: GetRecipeQuestionsUseCaseProtocol,
        generateRecipeUseCase: GenerateRecipeUseCaseProtocol,
        saveRecipeUseCase: SaveRecipeUseCaseProtocol,
        getSavedRecipesUseCase: GetSavedRecipesUseCaseProtocol,
        getSavedRecipeUseCase: GetSavedRecipeUseCaseProtocol,
        removeSavedRecipeUseCase: RemoveSavedRecipeUseCaseProtocol,
        onFinish: @escaping () -> Void,
        onDismiss: @escaping () -> Void = {}
    ) {
        self.getRecipeQuestionsUseCase = getRecipeQuestionsUseCase
        self.saveRecipeUseCase = saveRecipeUseCase
        self.getSavedRecipesUseCase = getSavedRecipesUseCase
        self.removeSavedRecipeUseCase = removeSavedRecipeUseCase
        self.onDismiss = onDismiss
        _viewModel = StateObject(
            wrappedValue: RecipeFlowViewModel(
                entryPoint: entryPoint,
                generateRecipeUseCase: generateRecipeUseCase,
                getSavedRecipeUseCase: getSavedRecipeUseCase,
                onFinish: onFinish
            )
        )
    }

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            rootView
                .navigationDestination(for: RecipeRoute.self) { route in
                    switch route {
                    case .creation:
                        ingredientPicker
                    case .questions:
                        QuestionStepperView(
                            viewModel: QuestionStepperViewModel(
                                questions: viewModel.questions,
                                onBack: { viewModel.goBack() },
                                onComplete: { viewModel.generateRecipe(answers: $0) }
                            )
                        )
                    case .result:
                        if let recipe = viewModel.recipe, let resultContext = viewModel.resultContext {
                            let showsGoHome = resultContext == .generated && viewModel.entryPoint == .creation
                            RecipeResultView(
                                recipe: recipe,
                                context: resultContext,
                                saveRecipeUseCase: saveRecipeUseCase,
                                removeSavedRecipeUseCase: removeSavedRecipeUseCase,
                                onGoHome: showsGoHome ? { viewModel.finishFlow() } : nil,
                                onBack: { viewModel.goBack() },
                                onRecipeRemoved: { viewModel.goBack() }
                            )
                        }
                    }
                }
        }
        .overlay {
            if viewModel.isGenerating {
                RecipeGenerationLoadingView()
            }
        }
        .dsToast(request: toastRequest, onDismiss: { _ in toastRequest = nil })
        .onChange(of: viewModel.feedback?.id) { _ in
            guard let feedback = viewModel.feedback else { return }
            toastRequest = DSToastRequest(message: Self.toastMessage(for: feedback), style: .error)
        }
        .onDisappear {
            viewModel.cancelGeneration()
            onDismiss()
        }
    }

    @ViewBuilder private var rootView: some View {
        switch viewModel.entryPoint {
        case .creation:
            ingredientPicker
        case .myRecipes:
            SavedRecipesView(
                viewModel: SavedRecipesViewModel(getSavedRecipesUseCase: getSavedRecipesUseCase),
                onBack: { viewModel.goBack() },
                onCreateRecipe: { viewModel.openCreation() },
                onSelectRecipe: { viewModel.openSavedRecipe(id: $0) }
            )
        }
    }

    private var ingredientPicker: IngredientPickerView {
        IngredientPickerView(
            viewModel: IngredientPickerViewModel(getRecipeQuestionsUseCase: getRecipeQuestionsUseCase),
            onBack: { viewModel.goBack() },
            onQuestionsLoaded: { viewModel.openQuestions(ingredients: $0, questions: $1) }
        )
    }

    private static func toastMessage(for feedback: RecipeFlowFeedback) -> String {
        switch feedback.kind {
        case .invalidIngredients: L10n.RecipeFlow.invalidIngredientsToast
        case .rateLimited: L10n.RecipeFlow.rateLimitedToast
        case .temporarilyUnavailable: L10n.RecipeFlow.temporarilyUnavailableToast
        case .noConnection: L10n.RecipeFlow.noConnectionToast
        case .generationFailed: L10n.RecipeResult.generationError
        case .savedRecipeUnavailable: L10n.MyRecipes.loadError
        }
    }
}
