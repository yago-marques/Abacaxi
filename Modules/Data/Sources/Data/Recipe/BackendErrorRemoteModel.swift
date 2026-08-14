import Foundation

enum BackendErrorCode: String {
    case invalidIngredients = "INVALID_INGREDIENTS"
    case tooFewIngredients = "TOO_FEW_INGREDIENTS"
    case rateLimited = "RATE_LIMITED"
    case llmTimeout = "LLM_TIMEOUT"
    case llmInvalidResponse = "LLM_INVALID_RESPONSE"
    case recipeValidationFailed = "RECIPE_VALIDATION_FAILED"
}

struct BackendErrorRemoteModel: Decodable {
    struct Detail: Decodable {
        let error: ErrorDetail
    }

    struct ErrorDetail: Decodable {
        let code: String
    }

    let detail: Detail

    static func code(from data: Data?) -> BackendErrorCode? {
        guard let data,
              let response = try? JSONDecoder().decode(BackendErrorRemoteModel.self, from: data) else {
            return nil
        }
        return BackendErrorCode(rawValue: response.detail.error.code)
    }
}
