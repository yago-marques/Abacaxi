import DataInterfaces
import DomainInterfaces

public enum GetRecipeQuestionsUseCaseFactory {
    public static func make(
        deviceIDRepository: DeviceIDRepositoryProtocol,
        recipeQuestionsRepository: RecipeQuestionsRepositoryProtocol
    ) -> GetRecipeQuestionsUseCaseProtocol {
        GetRecipeQuestionsUseCase(
            deviceIDRepository: deviceIDRepository,
            recipeQuestionsRepository: recipeQuestionsRepository
        )
    }
}

public final class GetRecipeQuestionsUseCase: GetRecipeQuestionsUseCaseProtocol {
    private let deviceIDRepository: DeviceIDRepositoryProtocol
    private let recipeQuestionsRepository: RecipeQuestionsRepositoryProtocol

    public init(
        deviceIDRepository: DeviceIDRepositoryProtocol,
        recipeQuestionsRepository: RecipeQuestionsRepositoryProtocol
    ) {
        self.deviceIDRepository = deviceIDRepository
        self.recipeQuestionsRepository = recipeQuestionsRepository
    }

    public func execute(ingredients: [RecipeIngredientBusinessModel]) async throws -> [RecipeQuestionBusinessModel] {
        guard IngredientLimits.range.contains(ingredients.count) else {
            throw GetRecipeQuestionsError.invalidIngredientCount
        }
        guard let deviceID = try deviceIDRepository.load() else {
            throw GetRecipeQuestionsError.missingDeviceID
        }
        do {
            return try await recipeQuestionsRepository.fetchQuestions(deviceID: deviceID, ingredients: ingredients)
        } catch let error as RecipeQuestionsRepositoryError {
            throw switch error {
            case .invalidIngredients: GetRecipeQuestionsError.invalidIngredients
            case .rateLimited: GetRecipeQuestionsError.rateLimited
            case .temporarilyUnavailable: GetRecipeQuestionsError.temporarilyUnavailable
            case .invalidResponse: GetRecipeQuestionsError.invalidResponse
            case .network: GetRecipeQuestionsError.noConnection
            case .cancelled: GetRecipeQuestionsError.cancelled
            }
        }
    }
}
