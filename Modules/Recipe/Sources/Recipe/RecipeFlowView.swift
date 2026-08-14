import DesignSystem
import DomainInterfaces
import SwiftUI

struct RecipeFlowView: View {
    @StateObject private var viewModel: RecipeFlowViewModel

    private let getRecipeQuestionsUseCase: GetRecipeQuestionsUseCaseProtocol
    private let generateRecipeUseCase: GenerateRecipeUseCaseProtocol
    private let saveRecipeUseCase: SaveRecipeUseCaseProtocol
    private let getSavedRecipesUseCase: GetSavedRecipesUseCaseProtocol
    private let getSavedRecipeUseCase: GetSavedRecipeUseCaseProtocol
    private let removeSavedRecipeUseCase: RemoveSavedRecipeUseCaseProtocol
    @State private var toastRequest: DSToastRequest?

    init(
        entryPoint: RecipeModuleFactory.EntryPoint,
        getRecipeQuestionsUseCase: GetRecipeQuestionsUseCaseProtocol,
        generateRecipeUseCase: GenerateRecipeUseCaseProtocol,
        saveRecipeUseCase: SaveRecipeUseCaseProtocol,
        getSavedRecipesUseCase: GetSavedRecipesUseCaseProtocol,
        getSavedRecipeUseCase: GetSavedRecipeUseCaseProtocol,
        removeSavedRecipeUseCase: RemoveSavedRecipeUseCaseProtocol,
        onFinish: @escaping () -> Void
    ) {
        self.getRecipeQuestionsUseCase = getRecipeQuestionsUseCase
        self.generateRecipeUseCase = generateRecipeUseCase
        self.saveRecipeUseCase = saveRecipeUseCase
        self.getSavedRecipesUseCase = getSavedRecipesUseCase
        self.getSavedRecipeUseCase = getSavedRecipeUseCase
        self.removeSavedRecipeUseCase = removeSavedRecipeUseCase
        _viewModel = StateObject(
            wrappedValue: RecipeFlowViewModel(entryPoint: entryPoint, onFinish: onFinish)
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
                                onBack: viewModel.goBack,
                                onComplete: generateRecipe
                            )
                        )
                    case .result:
                        if let recipe = viewModel.recipe, let resultContext = viewModel.resultContext {
                            RecipeResultView(
                                recipe: recipe,
                                context: resultContext,
                                saveRecipeUseCase: saveRecipeUseCase,
                                removeSavedRecipeUseCase: removeSavedRecipeUseCase,
                                onGoHome: resultContext == .generated && viewModel.entryPoint == .creation
                                    ? viewModel.finishFlow
                                    : nil,
                                onBack: viewModel.goBack,
                                onRecipeRemoved: viewModel.goBack
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
    }

    @ViewBuilder private var rootView: some View {
        switch viewModel.entryPoint {
        case .creation:
            ingredientPicker
        case .myRecipes:
            SavedRecipesView(
                viewModel: SavedRecipesViewModel(getSavedRecipesUseCase: getSavedRecipesUseCase),
                onBack: viewModel.goBack,
                onCreateRecipe: viewModel.openCreation,
                onSelectRecipe: openSavedRecipe
            )
        }
    }

    private var ingredientPicker: IngredientPickerView {
        IngredientPickerView(
            viewModel: IngredientPickerViewModel(getRecipeQuestionsUseCase: getRecipeQuestionsUseCase),
            onBack: viewModel.goBack,
            onQuestionsLoaded: openQuestions
        )
    }

    private func openQuestions(
        ingredients: [RecipeIngredientBusinessModel],
        questions: [RecipeQuestionPresentationModel]
    ) {
        viewModel.openQuestions(ingredients: ingredients, questions: questions)
        if questions.isEmpty { generateRecipe([]) }
    }

    private func generateRecipe(_ answers: [RecipeAnswerBusinessModel]) {
        viewModel.startGeneration()
        Task {
            do {
                let recipe = try await generateRecipeUseCase.execute(
                    ingredients: viewModel.ingredients,
                    answers: answers
                )
                await MainActor.run { viewModel.showGeneratedRecipe(recipe) }
            } catch {
                await MainActor.run {
                    viewModel.finishGeneration()
                    toastRequest = DSToastRequest(message: L10n.RecipeResult.generationError, style: .error)
                }
            }
        }
    }

    private func openSavedRecipe(id: String) {
        do {
            guard let recipe = try getSavedRecipeUseCase.execute(id: id) else { return }
            viewModel.showSavedRecipe(recipe, id: id)
        } catch {
            toastRequest = DSToastRequest(message: L10n.MyRecipes.loadError, style: .error)
        }
    }
}
