import DataInterfaces
import DomainInterfaces
import Foundation
import NetworkInterfaces
import XCTest
@testable import Data

final class RecipeRepositoryTests: XCTestCase {
    func test_fetchRecipe_sendsAuthenticatedPostRequestWithEncodedIngredientsAndAnswers() async throws {
        let (sut, doubles) = makeSUTAndDoubles()
        let deviceID = UUID()

        _ = try await sut.fetchRecipe(deviceID: deviceID, ingredients: ingredients, answers: answers)

        XCTAssertEqual(doubles.receivedEndpoint?.path, "/v1/recipe")
        XCTAssertEqual(doubles.receivedEndpoint?.method, .post)
        XCTAssertEqual(doubles.receivedEndpoint?.headers["X-Device-ID"], deviceID.uuidString)
        XCTAssertEqual(doubles.receivedEndpoint?.headers["X-API-Key"], "api-key")
        XCTAssertEqual(doubles.receivedEndpoint?.headers["Content-Type"], "application/json")
        let body = try XCTUnwrap(doubles.receivedEndpoint?.body)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: [[String: String]]])
        XCTAssertEqual(object["ingredients"], [
            ["name": "Arroz", "amount": "pouco"],
            ["name": "Feijão", "amount": "medio"],
            ["name": "Ovo", "amount": "muito"]
        ])
        XCTAssertEqual(object["answers"], [
            ["question_id": "q1", "value": "Sim"]
        ])
    }

    func test_fetchRecipe_mapsRemoteRecipeWithNutritionToBusinessModel() async throws {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.stubbedData = Data("""
        {
            "title": "Risoto",
            "description": "Cremoso",
            "ingredients": [
                { "name": "Arroz", "quantity": "1 xícara" },
                { "name": "Feijão", "quantity": "2 conchas" }
            ],
            "steps": ["Refogue", "Cozinhe"],
            "prep_time_minutes": 40,
            "servings": 3,
            "nutrition_info": { "calories": 450, "protein_g": 12, "carbs_g": 60, "fat_g": 10 },
            "image_base64": null
        }
        """.utf8)

        let result = try await sut.fetchRecipe(deviceID: UUID(), ingredients: ingredients, answers: answers)

        XCTAssertEqual(result.title, "Risoto")
        XCTAssertEqual(result.description, "Cremoso")
        XCTAssertEqual(result.ingredients, [
            .init(name: "Arroz", quantity: "1 xícara"),
            .init(name: "Feijão", quantity: "2 conchas")
        ])
        XCTAssertEqual(result.steps, ["Refogue", "Cozinhe"])
        XCTAssertEqual(result.preparationTimeMinutes, 40)
        XCTAssertEqual(result.servings, 3)
        XCTAssertEqual(result.nutrition, .init(calories: 450, proteinGrams: 12, carbsGrams: 60, fatGrams: 10))
        XCTAssertNil(result.imageData)
    }

    func test_fetchRecipe_withNullNutrition_returnsRecipeWithoutNutrition() async throws {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.stubbedData = Data("""
        {
            "title": "Risoto",
            "description": "Cremoso",
            "ingredients": [{ "name": "Arroz", "quantity": "1 xícara" }],
            "steps": ["Cozinhe"],
            "prep_time_minutes": 40,
            "servings": 3,
            "nutrition_info": null,
            "image_base64": null
        }
        """.utf8)

        let result = try await sut.fetchRecipe(deviceID: UUID(), ingredients: ingredients, answers: answers)

        XCTAssertNil(result.nutrition)
        XCTAssertNil(result.imageData)
    }

    func test_fetchRecipe_mapsEachBackendErrorCodeToRepositoryError() async {
        let expectedMappings: [(code: String, repositoryError: RecipeRepositoryError)] = [
            ("INVALID_INGREDIENTS", .invalidIngredients),
            ("TOO_FEW_INGREDIENTS", .invalidIngredients),
            ("RATE_LIMITED", .rateLimited),
            ("LLM_TIMEOUT", .temporarilyUnavailable),
            ("LLM_INVALID_RESPONSE", .temporarilyUnavailable),
            ("RECIPE_VALIDATION_FAILED", .temporarilyUnavailable),
            ("UNKNOWN_CODE", .invalidResponse)
        ]

        for (code, repositoryError) in expectedMappings {
            let (sut, doubles) = makeSUTAndDoubles()
            doubles.stubbedError = NetworkError.statusCode(422, data: Data("""
            { "detail": { "error": { "code": "\(code)", "message": "ignored" } } }
            """.utf8))

            await XCTAssertThrowsErrorAsync(
                try await sut.fetchRecipe(deviceID: UUID(), ingredients: ingredients, answers: answers)
            ) { error in
                XCTAssertEqual(
                    error as? RecipeRepositoryError,
                    repositoryError,
                    "expected \(code) to map to \(repositoryError)"
                )
            }
        }
    }

    func test_fetchRecipe_mapsUndecodableErrorBodyToInvalidResponse() async {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.stubbedError = NetworkError.statusCode(422, data: Data("[]".utf8))

        await XCTAssertThrowsErrorAsync(
            try await sut.fetchRecipe(deviceID: UUID(), ingredients: ingredients, answers: answers)
        ) { error in
            XCTAssertEqual(error as? RecipeRepositoryError, .invalidResponse)
        }
    }

    func test_fetchRecipe_mapsTransportFailureToNetworkError() async {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.stubbedError = NetworkError.transport(URLError(.notConnectedToInternet))

        await XCTAssertThrowsErrorAsync(
            try await sut.fetchRecipe(deviceID: UUID(), ingredients: ingredients, answers: answers)
        ) { error in
            XCTAssertEqual(error as? RecipeRepositoryError, .network)
        }
    }

    func test_fetchRecipe_mapsCancellationToCancelledError() async {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.stubbedError = NetworkError.cancelled

        await XCTAssertThrowsErrorAsync(
            try await sut.fetchRecipe(deviceID: UUID(), ingredients: ingredients, answers: answers)
        ) { error in
            XCTAssertEqual(error as? RecipeRepositoryError, .cancelled)
        }
    }
}

private extension RecipeRepositoryTests {
    var ingredients: [RecipeIngredientBusinessModel] {
        [
            .init(name: "Arroz", amount: .little),
            .init(name: "Feijão", amount: .medium),
            .init(name: "Ovo", amount: .much)
        ]
    }

    var answers: [RecipeAnswerBusinessModel] {
        [.init(questionID: "q1", value: "Sim")]
    }

    func makeSUTAndDoubles() -> (sut: RecipeRepository, doubles: HTTPClientStub) {
        let httpClient = HTTPClientStub()
        httpClient.stubbedData = Data("""
        {
            "title": "Risoto",
            "description": "Cremoso",
            "ingredients": [{ "name": "Arroz", "quantity": "1 xícara" }],
            "steps": ["Cozinhe"],
            "prep_time_minutes": 40,
            "servings": 3,
            "nutrition_info": null,
            "image_base64": null
        }
        """.utf8)
        return (RecipeRepository(httpClient: httpClient, apiKey: "api-key"), httpClient)
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
