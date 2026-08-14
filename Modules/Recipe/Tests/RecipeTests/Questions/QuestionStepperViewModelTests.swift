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

    @Test func recipeFlow_openQuestions_ignoresEmptyCollection() {
        let sut = RecipeFlowViewModel(entryPoint: .creation, onFinish: {})

        sut.openQuestions(ingredients: [], questions: [])

        #expect(sut.path.isEmpty)
    }

    @Test func recipeFlow_openQuestions_storesQuestionsAndAddsStepperRoute() {
        let sut = RecipeFlowViewModel(entryPoint: .creation, onFinish: {})

        sut.openQuestions(ingredients: [], questions: questions)

        #expect(sut.questions == questions)
        #expect(sut.path == [.questions])
    }

    @Test func recipeFlow_finishFlow_callsTheFlowCompletion() {
        var didFinish = false
        let sut = RecipeFlowViewModel(entryPoint: .creation) {
            didFinish = true
        }

        sut.finishFlow()

        #expect(didFinish)
    }

    @Test func recipeFlow_showGeneratedRecipe_setsGeneratedResultContext() {
        let sut = RecipeFlowViewModel(entryPoint: .creation, onFinish: {})

        sut.showGeneratedRecipe(recipe)

        #expect(sut.resultContext == .generated)
    }

    @Test func recipeFlow_showSavedRecipe_setsSavedResultContext() {
        let sut = RecipeFlowViewModel(entryPoint: .myRecipes, onFinish: {})

        sut.showSavedRecipe(recipe, id: "saved-id")

        #expect(sut.resultContext == .saved(id: "saved-id"))
    }
}

private extension QuestionStepperViewModelTests {
    var questions: [RecipeQuestionPresentationModel] {
        [
            .init(id: "type", text: "Qual prato?", options: ["Massa", "Rápido"], allowsCustomAnswer: true),
            .init(id: "time", text: "Quanto tempo?", options: ["30 minutos"], allowsCustomAnswer: false)
        ]
    }

    var recipe: RecipeBusinessModel {
        RecipeBusinessModel(
            title: "Receita",
            description: "Descrição",
            ingredients: [],
            steps: [],
            preparationTimeMinutes: 20,
            servings: 2,
            nutrition: nil,
            imageData: nil
        )
    }

    func makeSUT(questions: [RecipeQuestionPresentationModel]? = nil) -> QuestionStepperViewModel {
        QuestionStepperViewModel(
            questions: questions ?? self.questions,
            onBack: {},
            onComplete: { _ in }
        )
    }
}
