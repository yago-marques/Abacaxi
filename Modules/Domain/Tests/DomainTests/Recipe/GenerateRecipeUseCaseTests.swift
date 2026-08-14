import DataInterfaces
import DomainInterfaces
import Foundation
import XCTest
@testable import Domain

final class GenerateRecipeUseCaseTests: XCTestCase {
    func test_execute_withValidIngredients_returnsRecipeAndForwardsArguments() async throws {
        let (sut, doubles) = makeSUTAndDoubles()
        let deviceID = UUID()
        let recipe = makeRecipe()
        doubles.deviceIDRepository.stubbedLoadResult = deviceID
        doubles.recipeRepository.stubbedResult = .success(recipe)

        let result = try await sut.execute(ingredients: ingredients, answers: answers)

        XCTAssertEqual(result, recipe)
        XCTAssertEqual(doubles.recipeRepository.receivedDeviceIDs, [deviceID])
        XCTAssertEqual(doubles.recipeRepository.receivedIngredients, [ingredients])
        XCTAssertEqual(doubles.recipeRepository.receivedAnswers, [answers])
    }

    func test_execute_withOneIngredient_throwsInvalidIngredientCountWithoutRequest() async {
        let (sut, doubles) = makeSUTAndDoubles()

        await XCTAssertThrowsErrorAsync(
            try await sut.execute(ingredients: makeIngredients(count: 1), answers: answers)
        ) { error in
            XCTAssertEqual(error as? GenerateRecipeError, .invalidIngredientCount)
        }

        XCTAssertTrue(doubles.recipeRepository.receivedDeviceIDs.isEmpty)
    }

    func test_execute_withSixteenIngredients_throwsInvalidIngredientCountWithoutRequest() async {
        let (sut, doubles) = makeSUTAndDoubles()

        await XCTAssertThrowsErrorAsync(
            try await sut.execute(ingredients: makeIngredients(count: 16), answers: answers)
        ) { error in
            XCTAssertEqual(error as? GenerateRecipeError, .invalidIngredientCount)
        }

        XCTAssertTrue(doubles.recipeRepository.receivedDeviceIDs.isEmpty)
    }

    func test_execute_withTwoIngredients_requestsRecipe() async throws {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.deviceIDRepository.stubbedLoadResult = UUID()
        doubles.recipeRepository.stubbedResult = .success(makeRecipe())

        _ = try await sut.execute(ingredients: makeIngredients(count: 2), answers: answers)

        XCTAssertEqual(doubles.recipeRepository.receivedDeviceIDs.count, 1)
    }

    func test_execute_withFifteenIngredients_requestsRecipe() async throws {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.deviceIDRepository.stubbedLoadResult = UUID()
        doubles.recipeRepository.stubbedResult = .success(makeRecipe())

        _ = try await sut.execute(ingredients: makeIngredients(count: 15), answers: answers)

        XCTAssertEqual(doubles.recipeRepository.receivedDeviceIDs.count, 1)
    }

    func test_execute_withNoDeviceID_throwsMissingDeviceIDWithoutRequest() async {
        let (sut, doubles) = makeSUTAndDoubles()

        await XCTAssertThrowsErrorAsync(try await sut.execute(ingredients: ingredients, answers: answers)) { error in
            XCTAssertEqual(error as? GenerateRecipeError, .missingDeviceID)
        }

        XCTAssertTrue(doubles.recipeRepository.receivedDeviceIDs.isEmpty)
    }

    func test_execute_whenRepositoryFails_mapsEachRepositoryErrorToDomainError() async {
        let expectedMappings: [(repositoryError: RecipeRepositoryError, domainError: GenerateRecipeError)] = [
            (.invalidIngredients, .invalidIngredients),
            (.rateLimited, .rateLimited),
            (.temporarilyUnavailable, .temporarilyUnavailable),
            (.invalidResponse, .invalidResponse),
            (.network, .noConnection),
            (.cancelled, .cancelled)
        ]

        for (repositoryError, domainError) in expectedMappings {
            let (sut, doubles) = makeSUTAndDoubles()
            doubles.deviceIDRepository.stubbedLoadResult = UUID()
            doubles.recipeRepository.stubbedResult = .failure(repositoryError)

            await XCTAssertThrowsErrorAsync(
                try await sut.execute(ingredients: ingredients, answers: answers)
            ) { error in
                XCTAssertEqual(
                    error as? GenerateRecipeError,
                    domainError,
                    "expected \(repositoryError) to map to \(domainError)"
                )
            }
        }
    }
}

private extension GenerateRecipeUseCaseTests {
    var ingredients: [RecipeIngredientBusinessModel] {
        [.init(name: "Arroz", amount: .medium), .init(name: "Feijão", amount: .much)]
    }

    var answers: [RecipeAnswerBusinessModel] {
        [.init(questionID: "q1", value: "Sim")]
    }

    func makeIngredients(count: Int) -> [RecipeIngredientBusinessModel] {
        (0..<count).map { .init(name: "Ingrediente \($0)", amount: .medium) }
    }

    func makeRecipe() -> RecipeBusinessModel {
        .init(
            title: "Receita",
            description: "Descrição",
            ingredients: [.init(name: "Arroz", quantity: "1 xícara")],
            steps: ["Cozinhe"],
            preparationTimeMinutes: 20,
            servings: 2,
            nutrition: nil,
            imageData: nil
        )
    }

    func makeSUTAndDoubles() -> (
        sut: GenerateRecipeUseCase,
        doubles: (deviceIDRepository: DeviceIDRepositoryStub, recipeRepository: RecipeRepositoryStub)
    ) {
        let deviceIDRepository = DeviceIDRepositoryStub()
        let recipeRepository = RecipeRepositoryStub()
        let sut = GenerateRecipeUseCase(
            deviceIDRepository: deviceIDRepository,
            recipeRepository: recipeRepository
        )
        return (sut, (deviceIDRepository, recipeRepository))
    }
}

private func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    _ errorHandler: (Error) -> Void
) async {
    do {
        _ = try await expression()
        XCTFail("Expected an error")
    } catch {
        errorHandler(error)
    }
}
