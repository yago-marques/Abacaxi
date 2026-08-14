import Testing
@testable import Recipe
import DomainInterfaces

@MainActor
struct IngredientPickerViewModelTests {
    @Test func addIngredient_addsTrimmedIngredientWithMediumAmount() {
        let sut = makeSUT()
        sut.draftText = "  Frango  "

        sut.addIngredient()

        #expect(sut.ingredients.map(\.name) == ["Frango"])
        #expect(sut.ingredients.map(\.amount) == [.medium])
        #expect(sut.draftText.isEmpty)
    }

    @Test func addIngredient_whenDuplicateAfterNormalization_keepsSingleIngredient() {
        let sut = makeSUT()
        sut.draftText = "Brócolis"
        sut.addIngredient()
        sut.draftText = "brocolis"

        sut.addIngredient()

        #expect(sut.ingredients.count == 1)
        #expect(sut.feedback != nil)
    }

    @Test func removeIngredient_removesOnlyTheRequestedIngredient() {
        let sut = makeSUT()
        add("Frango", to: sut)
        add("Arroz", to: sut)
        let id = sut.ingredients[0].id

        sut.removeIngredient(id: id)

        #expect(sut.ingredients.map(\.name) == ["Arroz"])
    }

    @Test func updateAmount_changesOnlyTheSelectedIngredient() {
        let sut = makeSUT()
        add("Frango", to: sut)
        add("Arroz", to: sut)
        sut.beginEditing(sut.ingredients[0])

        sut.updateAmount(.much)

        #expect(sut.ingredients[0].amount == .much)
        #expect(sut.ingredients[1].amount == .medium)
    }

    @Test func canContinue_requiresTwoToFifteenIngredients() {
        let sut = makeSUT()
        #expect(!sut.canContinue)
        add("Frango", to: sut)
        #expect(!sut.canContinue)
        add("Arroz", to: sut)
        #expect(sut.canContinue)
        for index in 3...15 { add("Ingrediente \(index)", to: sut) }
        #expect(sut.canContinue)
        add("Extra", to: sut)
        #expect(sut.ingredients.count == 15)
    }

    @Test func fetchQuestions_withQuestions_returnsPresentationModels() async {
        let useCase = GetRecipeQuestionsUseCaseStub()
        useCase.stubbedResult = .success([
            .init(id: "type", text: "Qual prato?", options: ["Massa"], allowsCustomAnswer: true)
        ])
        let sut = IngredientPickerViewModel(getRecipeQuestionsUseCase: useCase)
        add("Arroz", to: sut)
        add("Feijão", to: sut)

        let questions = await sut.fetchQuestions()

        #expect(questions?.map(\.id) == ["type"])
    }

    @Test func fetchQuestions_withQuestions_mapsBusinessModelsToPresentationState() async {
        let useCase = GetRecipeQuestionsUseCaseStub()
        useCase.stubbedResult = .success([.init(id: "q1", text: "Pergunta", options: ["A"], allowsCustomAnswer: true)])
        let sut = makeSUT(useCase: useCase)
        add("Frango", to: sut)
        add("Arroz", to: sut)

        _ = await sut.fetchQuestions()

        #expect(useCase.receivedIngredients == [[
            .init(name: "Frango", amount: .medium),
            .init(name: "Arroz", amount: .medium)
        ]])
        #expect(sut.questionsState == .questions([
            .init(id: "q1", text: "Pergunta", options: ["A"], allowsCustomAnswer: true)
        ]))
    }

    @Test func fetchQuestions_withEmptyResponse_keepsIngredientsAndMarksEmptyState() async {
        let useCase = GetRecipeQuestionsUseCaseStub()
        useCase.stubbedResult = .success([])
        let sut = makeSUT(useCase: useCase)
        add("Frango", to: sut)
        add("Arroz", to: sut)

        _ = await sut.fetchQuestions()

        #expect(sut.questionsState == .empty)
        #expect(sut.ingredients.map(\.name) == ["Frango", "Arroz"])
    }

    @Test func fetchQuestions_whenItFails_preservesIngredientsAndEmitsFeedback() async {
        let useCase = GetRecipeQuestionsUseCaseStub()
        useCase.stubbedResult = .failure(GetRecipeQuestionsError.rateLimited)
        let sut = makeSUT(useCase: useCase)
        add("Frango", to: sut)
        add("Arroz", to: sut)

        _ = await sut.fetchQuestions()

        #expect(sut.questionsState == .idle)
        #expect(sut.ingredients.map(\.name) == ["Frango", "Arroz"])
        #expect(sut.feedback?.kind == .rateLimited)
    }

    @Test func fetchQuestions_withInvalidIngredients_emitsFeedbackAfterTheRequest() async {
        let useCase = GetRecipeQuestionsUseCaseStub()
        useCase.stubbedResult = .failure(GetRecipeQuestionsError.invalidIngredients)
        let sut = makeSUT(useCase: useCase)
        add("Ingrediente inválido", to: sut)
        add("Arroz", to: sut)

        _ = await sut.fetchQuestions()

        #expect(sut.questionsState == .idle)
        #expect(sut.feedback?.kind == .invalidIngredients)
    }

    private func makeSUT(useCase: GetRecipeQuestionsUseCaseStub = .init()) -> IngredientPickerViewModel {
        if useCase.stubbedResult == nil {
            useCase.stubbedResult = .success([])
        }
        return IngredientPickerViewModel(getRecipeQuestionsUseCase: useCase)
    }

    private func add(_ name: String, to viewModel: IngredientPickerViewModel) {
        viewModel.draftText = name
        viewModel.addIngredient()
    }
}
