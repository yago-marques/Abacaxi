import DataInterfaces
import DomainInterfaces
import Foundation
import NetworkInterfaces
import XCTest
@testable import Data

final class RecipeQuestionsRepositoryTests: XCTestCase {
    func test_fetchQuestions_sendsAuthenticatedPostRequestWithEncodedIngredients() async throws {
        let (sut, doubles) = makeSUTAndDoubles()
        let deviceID = UUID()

        _ = try await sut.fetchQuestions(deviceID: deviceID, ingredients: ingredients)

        XCTAssertEqual(doubles.receivedEndpoint?.path, "/v1/questions")
        XCTAssertEqual(doubles.receivedEndpoint?.method, .post)
        XCTAssertEqual(doubles.receivedEndpoint?.headers["X-Device-ID"], deviceID.uuidString)
        XCTAssertEqual(doubles.receivedEndpoint?.headers["X-API-Key"], "api-key")
        XCTAssertEqual(doubles.receivedEndpoint?.headers["Content-Type"], "application/json")
        let body = try XCTUnwrap(doubles.receivedEndpoint?.body)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: [[String: String]]])
        XCTAssertEqual(object["ingredients"], [
            ["name": "Arroz", "amount": "medio"],
            ["name": "Feijão", "amount": "muito"]
        ])
    }

    func test_fetchQuestions_mapsRemoteQuestionsToBusinessModels() async throws {
        let (sut, _) = makeSUTAndDoubles()

        let result = try await sut.fetchQuestions(deviceID: UUID(), ingredients: ingredients)

        XCTAssertEqual(result, [question])
    }

    func test_fetchQuestions_mapsDomainErrorCode() async {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.stubbedError = NetworkError.statusCode(422, data: """
        { "detail": { "error": { "code": "INVALID_INGREDIENTS", "message": "ignored" } } }
        """.data(using: .utf8))

        await XCTAssertThrowsErrorAsync(try await sut.fetchQuestions(deviceID: UUID(), ingredients: ingredients)) { error in
            XCTAssertEqual(error as? RecipeQuestionsRepositoryError, .invalidIngredients)
        }
    }

    func test_fetchQuestions_mapsSchemaFailureToGenericError() async {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.stubbedError = NetworkError.statusCode(422, data: Data("[]".utf8))

        await XCTAssertThrowsErrorAsync(try await sut.fetchQuestions(deviceID: UUID(), ingredients: ingredients)) { error in
            XCTAssertEqual(error as? RecipeQuestionsRepositoryError, .invalidResponse)
        }
    }
}

private extension RecipeQuestionsRepositoryTests {
    var ingredients: [RecipeIngredientBusinessModel] {
        [.init(name: "Arroz", amount: .medium), .init(name: "Feijão", amount: .much)]
    }

    var question: RecipeQuestionBusinessModel {
        .init(id: "q1", text: "Pergunta", options: ["A", "B"], allowsCustomAnswer: true)
    }

    func makeSUTAndDoubles() -> (sut: RecipeQuestionsRepository, doubles: HTTPClientStub) {
        let httpClient = HTTPClientStub()
        httpClient.stubbedData = """
        { "questions": [{ "id": "q1", "text": "Pergunta", "options": ["A", "B"], "allow_custom": true }] }
        """.data(using: .utf8)
        return (RecipeQuestionsRepository(httpClient: httpClient, apiKey: "api-key"), httpClient)
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
