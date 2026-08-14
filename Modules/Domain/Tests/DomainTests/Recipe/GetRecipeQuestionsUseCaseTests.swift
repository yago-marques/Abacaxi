import DataInterfaces
import DomainInterfaces
import Foundation
import XCTest
@testable import Domain

final class GetRecipeQuestionsUseCaseTests: XCTestCase {
    func test_execute_withValidIngredients_returnsQuestions() async throws {
        let (sut, doubles) = makeSUTAndDoubles()
        let deviceID = UUID()
        doubles.deviceIDRepository.stubbedLoadResult = deviceID
        doubles.recipeQuestionsRepository.stubbedResult = .success([question])

        let result = try await sut.execute(ingredients: ingredients)

        XCTAssertEqual(result, [question])
        XCTAssertEqual(doubles.recipeQuestionsRepository.receivedDeviceIDs, [deviceID])
        XCTAssertEqual(doubles.recipeQuestionsRepository.receivedIngredients, [ingredients])
    }

    func test_execute_withNoDeviceID_throwsMissingDeviceIDWithoutRequest() async {
        let (sut, doubles) = makeSUTAndDoubles()

        await XCTAssertThrowsErrorAsync(try await sut.execute(ingredients: ingredients)) { error in
            XCTAssertEqual(error as? GetRecipeQuestionsError, .missingDeviceID)
        }

        XCTAssertTrue(doubles.recipeQuestionsRepository.receivedDeviceIDs.isEmpty)
    }

    func test_execute_withInvalidIngredientCount_throwsWithoutRequest() async {
        let (sut, doubles) = makeSUTAndDoubles()

        await XCTAssertThrowsErrorAsync(
            try await sut.execute(ingredients: [.init(name: "Arroz", amount: .medium)])
        ) { error in
            XCTAssertEqual(error as? GetRecipeQuestionsError, .invalidIngredientCount)
        }

        XCTAssertTrue(doubles.recipeQuestionsRepository.receivedDeviceIDs.isEmpty)
    }
}

private extension GetRecipeQuestionsUseCaseTests {
    var ingredients: [RecipeIngredientBusinessModel] {
        [.init(name: "Arroz", amount: .medium), .init(name: "Feijão", amount: .much)]
    }

    var question: RecipeQuestionBusinessModel {
        .init(id: "q1", text: "Pergunta", options: ["A", "B"], allowsCustomAnswer: true)
    }

    func makeSUTAndDoubles() -> (
        sut: GetRecipeQuestionsUseCase,
        doubles: (deviceIDRepository: DeviceIDRepositoryStub, recipeQuestionsRepository: RecipeQuestionsRepositoryStub)
    ) {
        let deviceIDRepository = DeviceIDRepositoryStub()
        let recipeQuestionsRepository = RecipeQuestionsRepositoryStub()
        let sut = GetRecipeQuestionsUseCase(
            deviceIDRepository: deviceIDRepository,
            recipeQuestionsRepository: recipeQuestionsRepository
        )
        return (sut, (deviceIDRepository, recipeQuestionsRepository))
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
