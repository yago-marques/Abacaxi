import Combine
import DomainInterfaces
import Foundation

@MainActor
protocol QuestionStepperViewModelProtocol: AnyObject {
    var currentQuestion: RecipeQuestionPresentationModel { get }
    var currentIndex: Int { get }
    var totalQuestions: Int { get }
    var progress: CGFloat { get }
    var selectedOption: String? { get }
    var customAnswer: String { get set }
    var isCustomAnswerSelected: Bool { get }
    var canContinue: Bool { get }
    var isLastQuestion: Bool { get }
    var isCompleted: Bool { get }
    func selectOption(_ option: String)
    func selectCustomAnswer()
    func continueStep()
    func goBack()
}

@MainActor
final class QuestionStepperViewModel: ObservableObject, QuestionStepperViewModelProtocol {
    private enum Answer: Equatable {
        case option(String)
        case custom(String)
    }

    private let questions: [RecipeQuestionPresentationModel]
    private let onBack: () -> Void
    private let onComplete: ([RecipeAnswerBusinessModel]) -> Void
    @Published private var answers: [String: Answer] = [:]
    @Published private(set) var currentIndex = 0
    @Published private(set) var isCompleted = false

    init(
        questions: [RecipeQuestionPresentationModel],
        onBack: @escaping () -> Void,
        onComplete: @escaping ([RecipeAnswerBusinessModel]) -> Void
    ) {
        precondition(!questions.isEmpty, "Question stepper requires at least one question")
        self.questions = questions
        self.onBack = onBack
        self.onComplete = onComplete
    }

    var currentQuestion: RecipeQuestionPresentationModel { questions[currentIndex] }
    var totalQuestions: Int { questions.count }
    var progress: CGFloat { CGFloat(currentIndex + 1) / CGFloat(totalQuestions) }
    var selectedOption: String? {
        guard case let .option(option) = answers[currentQuestion.id] else { return nil }
        return option
    }
    var customAnswer: String {
        get {
            guard case let .custom(answer) = answers[currentQuestion.id] else { return "" }
            return answer
        }
        set { answers[currentQuestion.id] = .custom(newValue) }
    }
    var isCustomAnswerSelected: Bool {
        guard case .custom = answers[currentQuestion.id] else { return false }
        return true
    }
    var canContinue: Bool {
        switch answers[currentQuestion.id] {
        case .option: true
        case let .custom(answer): !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case nil: false
        }
    }
    var isLastQuestion: Bool { currentIndex == questions.count - 1 }

    func selectOption(_ option: String) { answers[currentQuestion.id] = .option(option) }
    func selectCustomAnswer() { answers[currentQuestion.id] = .custom(customAnswer) }

    func continueStep() {
        guard canContinue else { return }
        guard !isLastQuestion else {
            isCompleted = true
            onComplete(answers.compactMap { questionID, answer in
                switch answer {
                case let .option(value):
                    .init(questionID: questionID, value: value)
                case let .custom(value):
                    .init(questionID: questionID, value: value.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            })
            return
        }
        currentIndex += 1
    }

    func goBack() {
        guard currentIndex > 0 else {
            onBack()
            return
        }
        currentIndex -= 1
    }
}
