import DomainInterfaces
import SwiftUI

enum RecipeRoute: Hashable {
    case creation
    case questions
    case result
}

enum RecipeResultContext: Equatable {
    case generated
    case saved(id: String)
}

struct RecipeFlowFeedback: Identifiable, Equatable {
    enum Kind: Equatable {
        case invalidIngredients
        case rateLimited
        case temporarilyUnavailable
        case noConnection
        case generationFailed
        case savedRecipeUnavailable
    }

    let id = UUID()
    let kind: Kind
}

@MainActor
final class RecipeFlowViewModel: ObservableObject {
    @Published var path: [RecipeRoute] = []
    @Published private(set) var questions: [RecipeQuestionPresentationModel] = []
    @Published private(set) var ingredients: [RecipeIngredientBusinessModel] = []
    @Published private(set) var recipe: RecipeBusinessModel?
    @Published private(set) var resultContext: RecipeResultContext?
    @Published private(set) var isGenerating = false
    @Published private(set) var feedback: RecipeFlowFeedback?
    let entryPoint: RecipeModuleFactory.EntryPoint
    private(set) var generationTask: Task<Void, Never>?

    private let generateRecipeUseCase: GenerateRecipeUseCaseProtocol
    private let getSavedRecipeUseCase: GetSavedRecipeUseCaseProtocol
    private let onFinish: () -> Void

    init(
        entryPoint: RecipeModuleFactory.EntryPoint,
        generateRecipeUseCase: GenerateRecipeUseCaseProtocol,
        getSavedRecipeUseCase: GetSavedRecipeUseCaseProtocol,
        onFinish: @escaping () -> Void
    ) {
        self.entryPoint = entryPoint
        self.generateRecipeUseCase = generateRecipeUseCase
        self.getSavedRecipeUseCase = getSavedRecipeUseCase
        self.onFinish = onFinish
    }

    deinit {
        generationTask?.cancel()
    }

    func openCreation() {
        path.append(.creation)
    }

    func openQuestions(
        ingredients: [RecipeIngredientBusinessModel],
        questions: [RecipeQuestionPresentationModel]
    ) {
        self.ingredients = ingredients
        self.questions = questions
        if questions.isEmpty {
            generateRecipe(answers: [])
        } else {
            path.append(.questions)
        }
    }

    func generateRecipe(answers: [RecipeAnswerBusinessModel]) {
        guard !isGenerating else { return }
        isGenerating = true
        generationTask = Task { [weak self] in
            await self?.performGeneration(answers: answers)
            self?.generationTask = nil
        }
    }

    func cancelGeneration() {
        generationTask?.cancel()
        generationTask = nil
    }

    func openSavedRecipe(id: String) {
        do {
            guard let recipe = try getSavedRecipeUseCase.execute(id: id) else { return }
            showSavedRecipe(recipe, id: id)
        } catch {
            feedback = RecipeFlowFeedback(kind: .savedRecipeUnavailable)
        }
    }

    func showGeneratedRecipe(_ recipe: RecipeBusinessModel) {
        self.recipe = recipe
        resultContext = .generated
        isGenerating = false
        path.append(.result)
    }

    func showSavedRecipe(_ recipe: RecipeBusinessModel, id: String) {
        self.recipe = recipe
        resultContext = .saved(id: id)
        path.append(.result)
    }

    func finishGeneration() {
        isGenerating = false
    }

    func finishFlow() {
        path.removeAll()
        onFinish()
    }

    func goBack() {
        guard path.isEmpty else {
            path.removeLast()
            return
        }
        onFinish()
    }
}

private extension RecipeFlowViewModel {
    func performGeneration(answers: [RecipeAnswerBusinessModel]) async {
        do {
            let recipe = try await generateRecipeUseCase.execute(ingredients: ingredients, answers: answers)
            guard !Task.isCancelled else {
                finishGeneration()
                return
            }
            showGeneratedRecipe(recipe)
        } catch GenerateRecipeError.cancelled {
            finishGeneration()
        } catch is CancellationError {
            finishGeneration()
        } catch let error as GenerateRecipeError {
            finishGeneration()
            feedback = RecipeFlowFeedback(kind: Self.feedbackKind(for: error))
        } catch {
            finishGeneration()
            feedback = RecipeFlowFeedback(kind: .generationFailed)
        }
    }

    static func feedbackKind(for error: GenerateRecipeError) -> RecipeFlowFeedback.Kind {
        switch error {
        case .invalidIngredientCount, .invalidIngredients: .invalidIngredients
        case .rateLimited: .rateLimited
        case .temporarilyUnavailable: .temporarilyUnavailable
        case .noConnection: .noConnection
        case .missingDeviceID, .invalidResponse, .cancelled: .generationFailed
        }
    }
}
