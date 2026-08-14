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

final class RecipeFlowViewModel: ObservableObject {
    @Published var path: [RecipeRoute] = []
    @Published private(set) var questions: [RecipeQuestionPresentationModel] = []
    @Published private(set) var ingredients: [RecipeIngredientBusinessModel] = []
    @Published private(set) var recipe: RecipeBusinessModel?
    @Published private(set) var resultContext: RecipeResultContext?
    @Published private(set) var isGenerating = false
    let entryPoint: RecipeModuleFactory.EntryPoint
    private let onFinish: () -> Void

    init(entryPoint: RecipeModuleFactory.EntryPoint, onFinish: @escaping () -> Void) {
        self.entryPoint = entryPoint
        self.onFinish = onFinish
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
            isGenerating = true
        } else {
            path.append(.questions)
        }
    }

    func startGeneration() {
        isGenerating = true
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
