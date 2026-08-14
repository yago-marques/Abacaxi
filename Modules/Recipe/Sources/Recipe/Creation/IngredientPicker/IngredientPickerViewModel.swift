import Combine
import DomainInterfaces
import Foundation

struct IngredientPickerFeedback: Identifiable {
    enum Kind: Equatable {
        case duplicate
        case invalidIngredients
        case rateLimited
        case temporarilyUnavailable
        case noConnection
        case requestFailed
    }

    let id = UUID()
    let kind: Kind
}

enum IngredientPickerQuestionsState: Equatable {
    case idle
    case loading
    case questions([RecipeQuestionPresentationModel])
    case empty
}

@MainActor
final class IngredientPickerViewModel: ObservableObject {
    @Published var draftText = ""
    @Published private(set) var ingredients: [IngredientPresentationModel] = []
    @Published var ingredientBeingEdited: IngredientPresentationModel?
    @Published private(set) var feedback: IngredientPickerFeedback?
    @Published private(set) var questionsState: IngredientPickerQuestionsState = .idle

    private let getRecipeQuestionsUseCase: GetRecipeQuestionsUseCaseProtocol

    init(getRecipeQuestionsUseCase: GetRecipeQuestionsUseCaseProtocol) {
        self.getRecipeQuestionsUseCase = getRecipeQuestionsUseCase
    }

    var canContinue: Bool {
        IngredientLimits.range.contains(ingredients.count)
    }

    func addIngredient() {
        let draft = IngredientPresentationModel(name: draftText)
        guard !draft.name.isEmpty, ingredients.count < IngredientLimits.maximum else { return }

        guard !ingredients.contains(where: { $0.normalizedName == draft.normalizedName }) else {
            feedback = IngredientPickerFeedback(kind: .duplicate)
            return
        }

        ingredients.append(draft)
        draftText = ""
        feedback = nil
    }

    func removeIngredient(id: UUID) {
        ingredients.removeAll { $0.id == id }
    }

    func dismissFeedback() {
        feedback = nil
    }

    func beginEditing(_ ingredient: IngredientPresentationModel) {
        ingredientBeingEdited = ingredient
    }

    func updateAmount(_ amount: IngredientAmount) {
        guard let ingredient = ingredientBeingEdited,
              let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) else {
            return
        }
        ingredients[index].amount = amount
        ingredientBeingEdited = nil
    }

    func fetchQuestions() async -> [RecipeQuestionPresentationModel]? {
        guard canContinue, questionsState != .loading else { return nil }

        questionsState = .loading
        let businessModels = ingredients.map { $0.toBusinessModel() }

        do {
            let questions = try await getRecipeQuestionsUseCase.execute(ingredients: businessModels)
            let presentationModels = questions.map(RecipeQuestionPresentationModel.init)
            questionsState = presentationModels.isEmpty ? .empty : .questions(presentationModels)
            return presentationModels
        } catch GetRecipeQuestionsError.cancelled {
            questionsState = .idle
            return nil
        } catch is CancellationError {
            questionsState = .idle
            return nil
        } catch let error as GetRecipeQuestionsError {
            questionsState = .idle
            feedback = IngredientPickerFeedback(kind: Self.feedbackKind(for: error))
            return nil
        } catch {
            questionsState = .idle
            feedback = IngredientPickerFeedback(kind: .requestFailed)
            return nil
        }
    }

    private static func feedbackKind(for error: GetRecipeQuestionsError) -> IngredientPickerFeedback.Kind {
        switch error {
        case .invalidIngredientCount, .invalidIngredients: .invalidIngredients
        case .rateLimited: .rateLimited
        case .temporarilyUnavailable: .temporarilyUnavailable
        case .noConnection: .noConnection
        case .missingDeviceID, .invalidResponse, .cancelled: .requestFailed
        }
    }
}
