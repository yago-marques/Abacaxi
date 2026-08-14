import DataInterfaces
import DomainInterfaces
import Foundation
import NetworkInterfaces

public enum RecipeQuestionsRepositoryFactory {
    public static func make(
        httpClient: HTTPClientProtocol,
        apiKey: String
    ) -> RecipeQuestionsRepositoryProtocol {
        RecipeQuestionsRepository(httpClient: httpClient, apiKey: apiKey)
    }
}

public final class RecipeQuestionsRepository: RecipeQuestionsRepositoryProtocol {
    private let httpClient: HTTPClientProtocol
    private let apiKey: String

    public init(httpClient: HTTPClientProtocol, apiKey: String) {
        self.httpClient = httpClient
        self.apiKey = apiKey
    }

    public func fetchQuestions(
        deviceID: UUID,
        ingredients: [RecipeIngredientBusinessModel]
    ) async throws -> [RecipeQuestionBusinessModel] {
        do {
            let response: RecipeQuestionsResponseRemoteModel = try await httpClient.send(
                try Endpoint(deviceID: deviceID, apiKey: apiKey, ingredients: ingredients)
            )
            return response.questions.map(RecipeQuestionBusinessModel.init)
        } catch let error as NetworkError {
            throw map(error)
        } catch {
            throw RecipeQuestionsRepositoryError.invalidResponse
        }
    }
}

private extension RecipeQuestionsRepository {
    struct Endpoint: HTTPEndpointProtocol {
        let deviceID: UUID
        let apiKey: String
        let body: Data?

        let path = "/v1/questions"
        let method: HTTPMethod = .post

        init(
            deviceID: UUID,
            apiKey: String,
            ingredients: [RecipeIngredientBusinessModel]
        ) throws {
            self.deviceID = deviceID
            self.apiKey = apiKey
            body = try JSONEncoder().encode(RecipeQuestionsRequestRemoteModel(ingredients: ingredients))
        }

        var headers: HTTPHeaders {
            [
                "Content-Type": "application/json",
                "X-Device-ID": deviceID.uuidString,
                "X-API-Key": apiKey
            ]
        }
    }

    func map(_ error: NetworkError) -> RecipeQuestionsRepositoryError {
        switch error {
        case let .statusCode(_, data): mapError(data: data)
        case .transport: .network
        case .cancelled: .cancelled
        case .invalidURL, .invalidResponse, .decoding: .invalidResponse
        }
    }

    func mapError(data: Data?) -> RecipeQuestionsRepositoryError {
        switch BackendErrorRemoteModel.code(from: data) {
        case .invalidIngredients, .tooFewIngredients: .invalidIngredients
        case .rateLimited: .rateLimited
        case .llmTimeout, .llmInvalidResponse, .recipeValidationFailed: .temporarilyUnavailable
        case nil: .invalidResponse
        }
    }
}

private struct RecipeQuestionsRequestRemoteModel: Encodable {
    let ingredients: [IngredientRemoteModel]

    init(ingredients: [RecipeIngredientBusinessModel]) {
        self.ingredients = ingredients.map(IngredientRemoteModel.init)
    }
}

private struct IngredientRemoteModel: Encodable {
    let name: String
    let amount: String

    init(_ businessModel: RecipeIngredientBusinessModel) {
        name = businessModel.name
        amount = businessModel.amount.remoteValue
    }
}

private struct RecipeQuestionsResponseRemoteModel: Decodable {
    let questions: [QuestionRemoteModel]
}

private struct QuestionRemoteModel: Decodable {
    let id: String
    let text: String
    let options: [String]
    let allowCustom: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case options
        case allowCustom = "allow_custom"
    }
}

private extension RecipeQuestionBusinessModel {
    init(_ remoteModel: QuestionRemoteModel) {
        self.init(
            id: remoteModel.id,
            text: remoteModel.text,
            options: remoteModel.options,
            allowsCustomAnswer: remoteModel.allowCustom
        )
    }
}
