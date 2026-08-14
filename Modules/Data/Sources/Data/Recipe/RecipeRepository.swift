import DataInterfaces
import DomainInterfaces
import Foundation
import NetworkInterfaces

public enum RecipeRepositoryFactory {
    public static func make(httpClient: HTTPClientProtocol, apiKey: String) -> RecipeRepositoryProtocol {
        RecipeRepository(httpClient: httpClient, apiKey: apiKey)
    }
}

public final class RecipeRepository: RecipeRepositoryProtocol {
    private let httpClient: HTTPClientProtocol
    private let apiKey: String

    public init(httpClient: HTTPClientProtocol, apiKey: String) {
        self.httpClient = httpClient
        self.apiKey = apiKey
    }

    public func fetchRecipe(
        deviceID: UUID,
        ingredients: [RecipeIngredientBusinessModel],
        answers: [RecipeAnswerBusinessModel]
    ) async throws -> RecipeBusinessModel {
        do {
            let response: RecipeResponseRemoteModel = try await httpClient.send(
                Endpoint(deviceID: deviceID, apiKey: apiKey, ingredients: ingredients, answers: answers)
            )
            return RecipeBusinessModel(response: response)
        } catch let NetworkError.statusCode(_, data) {
            throw mapError(data: data)
        }
    }
}

private extension RecipeRepository {
    struct Endpoint: HTTPEndpointProtocol {
        let deviceID: UUID
        let apiKey: String
        let ingredients: [RecipeIngredientBusinessModel]
        let answers: [RecipeAnswerBusinessModel]

        let path = "/v1/recipe"
        let method: HTTPMethod = .post

        var headers: HTTPHeaders {
            ["Content-Type": "application/json", "X-Device-ID": deviceID.uuidString, "X-API-Key": apiKey]
        }

        var body: Data? {
            try? JSONEncoder().encode(RecipeRequestRemoteModel(ingredients: ingredients, answers: answers))
        }
    }

    func mapError(data: Data?) -> RecipeRepositoryError {
        guard let data,
              let response = try? JSONDecoder().decode(RecipeErrorRemoteModel.self, from: data) else {
            return .invalidResponse
        }

        return switch response.detail.error.code {
        case "INVALID_INGREDIENTS", "TOO_FEW_INGREDIENTS": .invalidIngredients
        case "RATE_LIMITED": .rateLimited
        case "LLM_TIMEOUT", "LLM_INVALID_RESPONSE", "RECIPE_VALIDATION_FAILED": .temporarilyUnavailable
        default: .invalidResponse
        }
    }
}

private struct RecipeRequestRemoteModel: Encodable {
    let ingredients: [RecipeIngredientRemoteModel]
    let answers: [RecipeAnswerRemoteModel]

    init(ingredients: [RecipeIngredientBusinessModel], answers: [RecipeAnswerBusinessModel]) {
        self.ingredients = ingredients.map(RecipeIngredientRemoteModel.init)
        self.answers = answers.map(RecipeAnswerRemoteModel.init)
    }
}

private struct RecipeIngredientRemoteModel: Encodable {
    let name: String
    let amount: String

    init(_ businessModel: RecipeIngredientBusinessModel) {
        name = businessModel.name
        amount = switch businessModel.amount {
        case .little: "pouco"
        case .medium: "medio"
        case .much: "muito"
        }
    }
}

private struct RecipeAnswerRemoteModel: Encodable {
    let questionID: String
    let value: String

    enum CodingKeys: String, CodingKey { case questionID = "question_id", value }

    init(_ businessModel: RecipeAnswerBusinessModel) {
        questionID = businessModel.questionID
        value = businessModel.value
    }
}

private struct RecipeResponseRemoteModel: Decodable {
    let title: String
    let description: String
    let ingredients: [RecipeIngredientDetailRemoteModel]
    let steps: [String]
    let preparationTimeMinutes: Int
    let servings: Int
    let nutrition: RecipeNutritionRemoteModel?
    let imageBase64: String?

    enum CodingKeys: String, CodingKey {
        case title, description, ingredients, steps, servings
        case preparationTimeMinutes = "prep_time_minutes"
        case nutrition = "nutrition_info"
        case imageBase64 = "image_base64"
    }
}

private struct RecipeIngredientDetailRemoteModel: Decodable { let name: String; let quantity: String }
private struct RecipeNutritionRemoteModel: Decodable {
    let calories: Int
    let proteinGrams: Int
    let carbsGrams: Int
    let fatGrams: Int
    enum CodingKeys: String, CodingKey { case calories; case proteinGrams = "protein_g"; case carbsGrams = "carbs_g"; case fatGrams = "fat_g" }
}
private struct RecipeErrorRemoteModel: Decodable {
    struct Detail: Decodable { struct ErrorDetail: Decodable { let code: String }; let error: ErrorDetail }
    let detail: Detail
}

private extension RecipeBusinessModel {
    init(response: RecipeResponseRemoteModel) {
        self.init(
            title: response.title,
            description: response.description,
            ingredients: response.ingredients.map { .init(name: $0.name, quantity: $0.quantity) },
            steps: response.steps,
            preparationTimeMinutes: response.preparationTimeMinutes,
            servings: response.servings,
            nutrition: response.nutrition.map {
                .init(calories: $0.calories, proteinGrams: $0.proteinGrams, carbsGrams: $0.carbsGrams, fatGrams: $0.fatGrams)
            },
            imageData: response.imageBase64.flatMap { Data(base64Encoded: $0) }
        )
    }
}
