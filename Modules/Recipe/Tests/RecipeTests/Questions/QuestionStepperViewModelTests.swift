import DomainInterfaces
import Testing
@testable import Recipe

@MainActor
struct QuestionStepperViewModelTests {
    @Test func continueStep_withoutAnswer_keepsCurrentQuestion() {
        let sut = makeSUT()

        sut.continueStep()

        #expect(sut.currentIndex == 0)
        #expect(!sut.canContinue)
    }

    @Test func continueStep_withOption_advancesAndRetainsAnswer() {
        let sut = makeSUT()
        sut.selectOption("Massa")

        sut.continueStep()
        sut.goBack()

        #expect(sut.currentIndex == 0)
        #expect(sut.selectedOption == "Massa")
    }

    @Test func customAnswer_requiresNonEmptyText() {
        let sut = makeSUT()

        sut.selectCustomAnswer()
        #expect(!sut.canContinue)

        sut.customAnswer = "  Rápido  "
        #expect(sut.canContinue)
    }

    @Test func continueStep_onLastQuestion_completesLocally() {
        let sut = makeSUT(questions: [questions[0]])
        sut.selectOption("Massa")

        sut.continueStep()

        #expect(sut.isCompleted)
    }

    @Test func continueStep_onLastQuestion_trimsCustomAnswers() {
        var receivedAnswers: [RecipeAnswerBusinessModel] = []
        let sut = QuestionStepperViewModel(
            questions: [questions[0]],
            onBack: {},
            onComplete: { receivedAnswers = $0 }
        )
        sut.selectCustomAnswer()
        sut.customAnswer = "  Comida vegana  "

        sut.continueStep()

        #expect(receivedAnswers == [.init(questionID: "type", value: "Comida vegana")])
    }

    @Test func goBack_onFirstQuestion_finishesFlow() {
        var didRequestBack = false
        let sut = QuestionStepperViewModel(
            questions: questions,
            onBack: {
                didRequestBack = true
            },
            onComplete: { _ in }
        )

        sut.goBack()

        #expect(didRequestBack)
    }
}

private extension QuestionStepperViewModelTests {
    var questions: [RecipeQuestionPresentationModel] {
        [
            .init(id: "type", text: "Qual prato?", options: ["Massa", "Rápido"], allowsCustomAnswer: true),
            .init(id: "time", text: "Quanto tempo?", options: ["30 minutos"], allowsCustomAnswer: false)
        ]
    }

    func makeSUT(questions: [RecipeQuestionPresentationModel]? = nil) -> QuestionStepperViewModel {
        QuestionStepperViewModel(
            questions: questions ?? self.questions,
            onBack: {},
            onComplete: { _ in }
        )
    }
}
