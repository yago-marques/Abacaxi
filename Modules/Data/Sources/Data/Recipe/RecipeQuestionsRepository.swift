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
                Endpoint(deviceID: deviceID, apiKey: apiKey, ingredients: ingredients)
            )
            return response.questions.map(RecipeQuestionBusinessModel.init)
        } catch let NetworkError.statusCode(_, data) {
            throw mapError(data: data)
        }
    }
}

private extension RecipeQuestionsRepository {
    struct Endpoint: HTTPEndpointProtocol {
        let deviceID: UUID
        let apiKey: String
        let ingredients: [RecipeIngredientBusinessModel]

        let path = "/v1/questions"
        let method: HTTPMethod = .post

        var headers: HTTPHeaders {
            [
                "Content-Type": "application/json",
                "X-Device-ID": deviceID.uuidString,
                "X-API-Key": apiKey
            ]
        }

        var body: Data? {
            try? JSONEncoder().encode(RecipeQuestionsRequestRemoteModel(ingredients: ingredients))
        }
    }

    func mapError(data: Data?) -> RecipeQuestionsRepositoryError {
        guard let data,
              let response = try? JSONDecoder().decode(RecipeQuestionsErrorRemoteModel.self, from: data) else {
            return .invalidResponse
        }

        return switch response.detail.error.code {
        case "INVALID_INGREDIENTS", "TOO_FEW_INGREDIENTS": RecipeQuestionsRepositoryError.invalidIngredients
        case "RATE_LIMITED": RecipeQuestionsRepositoryError.rateLimited
        case "LLM_TIMEOUT", "LLM_INVALID_RESPONSE", "RECIPE_VALIDATION_FAILED": RecipeQuestionsRepositoryError.temporarilyUnavailable
        default: RecipeQuestionsRepositoryError.invalidResponse
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
        switch businessModel.amount {
        case .little: amount = "pouco"
        case .medium: amount = "medio"
        case .much: amount = "muito"
        }
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

private struct RecipeQuestionsErrorRemoteModel: Decodable {
    struct Detail: Decodable {
        struct ErrorDetail: Decodable {
            let code: String
        }

        let error: ErrorDetail
    }

    let detail: Detail
}
