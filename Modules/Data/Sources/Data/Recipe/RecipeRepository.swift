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
                try Endpoint(deviceID: deviceID, apiKey: apiKey, ingredients: ingredients, answers: answers)
            )
            return RecipeBusinessModel(response: response)
        } catch let error as NetworkError {
            throw map(error)
        } catch {
            throw RecipeRepositoryError.invalidResponse
        }
    }
}

private extension RecipeRepository {
    struct Endpoint: HTTPEndpointProtocol {
        let deviceID: UUID
        let apiKey: String
        let body: Data?

        let path = "/v1/recipe"
        let method: HTTPMethod = .post

        init(
            deviceID: UUID,
            apiKey: String,
            ingredients: [RecipeIngredientBusinessModel],
            answers: [RecipeAnswerBusinessModel]
        ) throws {
            self.deviceID = deviceID
            self.apiKey = apiKey
            body = try JSONEncoder().encode(RecipeRequestRemoteModel(ingredients: ingredients, answers: answers))
        }

        var headers: HTTPHeaders {
            ["Content-Type": "application/json", "X-Device-ID": deviceID.uuidString, "X-API-Key": apiKey]
        }
    }

    func map(_ error: NetworkError) -> RecipeRepositoryError {
        switch error {
        case let .statusCode(_, data): mapError(data: data)
        case .transport: .network
        case .cancelled: .cancelled
        case .invalidURL, .invalidResponse, .decoding: .invalidResponse
        }
    }

    func mapError(data: Data?) -> RecipeRepositoryError {
        switch BackendErrorRemoteModel.code(from: data) {
        case .invalidIngredients, .tooFewIngredients: .invalidIngredients
        case .rateLimited: .rateLimited
        case .llmTimeout, .llmInvalidResponse, .recipeValidationFailed: .temporarilyUnavailable
        case nil: .invalidResponse
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
        amount = businessModel.amount.remoteValue
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

private struct RecipeIngredientDetailRemoteModel: Decodable {
    let name: String
    let quantity: String
}

private struct RecipeNutritionRemoteModel: Decodable {
    let calories: Int
    let proteinGrams: Int
    let carbsGrams: Int
    let fatGrams: Int

    enum CodingKeys: String, CodingKey {
        case calories
        case proteinGrams = "protein_g"
        case carbsGrams = "carbs_g"
        case fatGrams = "fat_g"
    }
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
                .init(
                    calories: $0.calories,
                    proteinGrams: $0.proteinGrams,
                    carbsGrams: $0.carbsGrams,
                    fatGrams: $0.fatGrams
                )
            },
            imageData: response.imageBase64.flatMap { Data(base64Encoded: $0) }
        )
    }
}
