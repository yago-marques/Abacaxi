import Combine
import DomainInterfaces
import Foundation

struct IngredientPickerFeedback: Identifiable {
    enum Kind: Equatable {
        case duplicate
        case invalidIngredients
        case rateLimited
        case temporarilyUnavailable
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

final class IngredientPickerViewModel: ObservableObject {
    private enum Constants {
        static let minimumIngredients = 2
        static let maximumIngredients = 15
    }

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
        (Constants.minimumIngredients...Constants.maximumIngredients).contains(ingredients.count)
    }

    func addIngredient() {
        let draft = IngredientPresentationModel(name: draftText)
        guard !draft.name.isEmpty, ingredients.count < Constants.maximumIngredients else { return }

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
        let ingredients = await MainActor.run { [weak self] () -> [RecipeIngredientBusinessModel]? in
            guard let self,
                  self.canContinue,
                  self.questionsState != .loading else {
                return nil
            }

            self.questionsState = .loading
            return self.ingredients.map { $0.toBusinessModel() }
        }
        guard let ingredients else { return nil }

        do {
            let questions = try await getRecipeQuestionsUseCase.execute(ingredients: ingredients)
            await MainActor.run { [weak self] in
                self?.questionsState = questions.isEmpty
                    ? .empty
                    : .questions(questions.map(RecipeQuestionPresentationModel.init))
            }
            return questions.map(RecipeQuestionPresentationModel.init)
        } catch let error as GetRecipeQuestionsError {
            await MainActor.run { [weak self] in
                self?.questionsState = .idle
                self?.feedback = IngredientPickerFeedback(kind: Self.feedbackKind(for: error))
            }
            return nil
        } catch {
            await MainActor.run { [weak self] in
                self?.questionsState = .idle
                self?.feedback = IngredientPickerFeedback(kind: .requestFailed)
            }
            return nil
        }
    }

    private static func feedbackKind(for error: GetRecipeQuestionsError) -> IngredientPickerFeedback.Kind {
        switch error {
        case .invalidIngredientCount, .invalidIngredients: .invalidIngredients
        case .rateLimited: .rateLimited
        case .temporarilyUnavailable: .temporarilyUnavailable
        case .missingDeviceID, .invalidResponse: .requestFailed
        }
    }
}
