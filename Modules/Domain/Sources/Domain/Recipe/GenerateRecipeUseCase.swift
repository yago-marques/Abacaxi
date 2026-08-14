import DataInterfaces
import DomainInterfaces

public enum GenerateRecipeUseCaseFactory {
    public static func make(
        deviceIDRepository: DeviceIDRepositoryProtocol,
        recipeRepository: RecipeRepositoryProtocol
    ) -> GenerateRecipeUseCaseProtocol {
        GenerateRecipeUseCase(deviceIDRepository: deviceIDRepository, recipeRepository: recipeRepository)
    }
}

public final class GenerateRecipeUseCase: GenerateRecipeUseCaseProtocol {
    private let deviceIDRepository: DeviceIDRepositoryProtocol
    private let recipeRepository: RecipeRepositoryProtocol

    public init(
        deviceIDRepository: DeviceIDRepositoryProtocol,
        recipeRepository: RecipeRepositoryProtocol
    ) {
        self.deviceIDRepository = deviceIDRepository
        self.recipeRepository = recipeRepository
    }

    public func execute(
        ingredients: [RecipeIngredientBusinessModel],
        answers: [RecipeAnswerBusinessModel]
    ) async throws -> RecipeBusinessModel {
        guard (2...15).contains(ingredients.count) else { throw GenerateRecipeError.invalidIngredientCount }
        guard let deviceID = try deviceIDRepository.load() else { throw GenerateRecipeError.missingDeviceID }

        do {
            return try await recipeRepository.fetchRecipe(
                deviceID: deviceID,
                ingredients: ingredients,
                answers: answers
            )
        } catch let error as RecipeRepositoryError {
            throw switch error {
            case .invalidIngredients: GenerateRecipeError.invalidIngredients
            case .rateLimited: GenerateRecipeError.rateLimited
            case .temporarilyUnavailable: GenerateRecipeError.temporarilyUnavailable
            case .invalidResponse: GenerateRecipeError.invalidResponse
            }
        }
    }
}
