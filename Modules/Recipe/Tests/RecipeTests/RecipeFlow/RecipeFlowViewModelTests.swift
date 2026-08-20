import DomainInterfaces
import Testing
@testable import Recipe

@MainActor
struct RecipeFlowViewModelTests {
    @Test func openQuestions_storesQuestionsAndAddsStepperRoute() {
        let (sut, _) = makeSUTAndDoubles()

        sut.openQuestions(ingredients: ingredients, questions: questions)

        #expect(sut.questions == questions)
        #expect(sut.path == [.questions])
    }

    @Test func openQuestions_withEmptyQuestions_startsGenerationInsteadOfRouting() async {
        let (sut, doubles) = makeSUTAndDoubles()

        sut.openQuestions(ingredients: ingredients, questions: [])

        #expect(sut.isGenerating)
        #expect(sut.path.isEmpty)
        await sut.generationTask?.value
        #expect(doubles.generateRecipeUseCase.receivedAnswers == [[]])
    }

    @Test func generateRecipe_onSuccess_showsGeneratedRecipeAndForwardsArguments() async throws {
        let (sut, doubles) = makeSUTAndDoubles()

        sut.openQuestions(ingredients: ingredients, questions: [])
        await sut.generationTask?.value

        let expected = try doubles.generateRecipeUseCase.stubbedResult.get()
        #expect(doubles.generateRecipeUseCase.receivedIngredients == [ingredients])
        #expect(sut.recipe == expected)
        #expect(sut.resultContext == .generated)
        #expect(sut.path == [.result])
        #expect(!sut.isGenerating)
        #expect(sut.feedback == nil)
    }

    @Test(arguments: [
        (GenerateRecipeError.invalidIngredientCount, RecipeFlowFeedback.Kind.invalidIngredients),
        (GenerateRecipeError.invalidIngredients, RecipeFlowFeedback.Kind.invalidIngredients),
        (GenerateRecipeError.rateLimited, RecipeFlowFeedback.Kind.rateLimited),
        (GenerateRecipeError.temporarilyUnavailable, RecipeFlowFeedback.Kind.temporarilyUnavailable),
        (GenerateRecipeError.noConnection, RecipeFlowFeedback.Kind.noConnection),
        (GenerateRecipeError.invalidResponse, RecipeFlowFeedback.Kind.generationFailed),
        (GenerateRecipeError.missingDeviceID, RecipeFlowFeedback.Kind.generationFailed)
    ])
    func generateRecipe_onError_emitsSpecificFeedback(
        error: GenerateRecipeError,
        expectedKind: RecipeFlowFeedback.Kind
    ) async {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.generateRecipeUseCase.stubbedResult = .failure(error)

        sut.openQuestions(ingredients: ingredients, questions: [])
        await sut.generationTask?.value

        #expect(sut.feedback?.kind == expectedKind)
        #expect(!sut.isGenerating)
        #expect(sut.path.isEmpty)
    }

    @Test func cancelGeneration_resetsStateWithoutFeedback() async {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.generateRecipeUseCase.delayNanoseconds = 1_000_000_000

        sut.openQuestions(ingredients: ingredients, questions: [])
        let task = sut.generationTask
        sut.cancelGeneration()
        await task?.value

        #expect(!sut.isGenerating)
        #expect(sut.feedback == nil)
        #expect(sut.recipe == nil)
        #expect(sut.path.isEmpty)
    }

    @Test func generateRecipe_whileGenerating_ignoresNewRequests() async {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.generateRecipeUseCase.delayNanoseconds = 50_000_000

        sut.generateRecipe(answers: [])
        sut.generateRecipe(answers: [])
        await sut.generationTask?.value

        #expect(doubles.generateRecipeUseCase.receivedAnswers.count == 1)
    }

    @Test func openSavedRecipe_whenRecipeExists_showsSavedResult() async {
        let (sut, doubles) = makeSUTAndDoubles(entryPoint: .myRecipes)
        doubles.getSavedRecipeUseCase.stubbedResult = .success(recipe)

        sut.openSavedRecipe(id: "saved-id")
        let task = sut.savedRecipeLoadTask
        await task?.value

        #expect(sut.resultContext == .saved(id: "saved-id"))
        #expect(sut.path == [.result])
    }

    @Test func openSavedRecipe_whenUseCaseFails_emitsSavedRecipeUnavailableFeedback() async {
        let (sut, doubles) = makeSUTAndDoubles(entryPoint: .myRecipes)
        doubles.getSavedRecipeUseCase.stubbedResult = .failure(StubError.failure)

        sut.openSavedRecipe(id: "saved-id")
        let task = sut.savedRecipeLoadTask
        await task?.value

        #expect(sut.feedback?.kind == .savedRecipeUnavailable)
        #expect(sut.path.isEmpty)
    }

    @Test func openSavedRecipe_whileLoading_ignoresNewRequests() async {
        let (sut, doubles) = makeSUTAndDoubles(entryPoint: .myRecipes)

        sut.openSavedRecipe(id: "saved-id")
        let task = sut.savedRecipeLoadTask
        sut.openSavedRecipe(id: "saved-id")
        await task?.value

        #expect(doubles.getSavedRecipeUseCase.receivedIDs == ["saved-id"])
    }

    @Test func finishFlow_callsTheFlowCompletion() {
        var didFinish = false
        let (sut, _) = makeSUTAndDoubles(onFinish: { didFinish = true })

        sut.finishFlow()

        #expect(didFinish)
    }

    @Test func showGeneratedRecipe_setsGeneratedResultContext() {
        let (sut, _) = makeSUTAndDoubles()

        sut.showGeneratedRecipe(recipe)

        #expect(sut.resultContext == .generated)
    }

    @Test func showSavedRecipe_setsSavedResultContext() {
        let (sut, _) = makeSUTAndDoubles(entryPoint: .myRecipes)

        sut.showSavedRecipe(recipe, id: "saved-id")

        #expect(sut.resultContext == .saved(id: "saved-id"))
    }
}

private extension RecipeFlowViewModelTests {
    private typealias SUT = RecipeFlowViewModel
    private typealias Doubles = (
        generateRecipeUseCase: GenerateRecipeUseCaseStub,
        getSavedRecipeUseCase: GetSavedRecipeUseCaseStub
    )

    private enum StubError: Error {
        case failure
    }

    private func makeSUTAndDoubles(
        entryPoint: RecipeModuleFactory.EntryPoint = .creation,
        onFinish: @escaping () -> Void = {}
    ) -> (sut: SUT, doubles: Doubles) {
        let generateRecipeUseCase = GenerateRecipeUseCaseStub()
        let getSavedRecipeUseCase = GetSavedRecipeUseCaseStub()
        let sut = RecipeFlowViewModel(
            entryPoint: entryPoint,
            generateRecipeUseCase: generateRecipeUseCase,
            getSavedRecipeUseCase: getSavedRecipeUseCase,
            onFinish: onFinish
        )
        return (sut, (generateRecipeUseCase, getSavedRecipeUseCase))
    }

    private var questions: [RecipeQuestionPresentationModel] {
        [
            .init(id: "type", text: "Qual prato?", options: ["Massa", "Rápido"], allowsCustomAnswer: true),
            .init(id: "time", text: "Quanto tempo?", options: ["30 minutos"], allowsCustomAnswer: false)
        ]
    }

    private var ingredients: [RecipeIngredientBusinessModel] {
        [
            RecipeIngredientBusinessModel(name: "Abacaxi", amount: .medium),
            RecipeIngredientBusinessModel(name: "Hortelã", amount: .little)
        ]
    }

    private var recipe: RecipeBusinessModel {
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
}
