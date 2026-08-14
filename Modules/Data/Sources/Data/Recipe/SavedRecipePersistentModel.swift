import Foundation
import PersistenceInterfaces

public struct SavedRecipePersistentModel: PersistentEntityProtocol, Equatable {
    public let id: String
    public let title: String
    public let recipeDescription: String
    public let ingredientsData: Data
    public let stepsData: Data
    public let preparationTimeMinutes: Int
    public let servings: Int
    public let nutritionData: Data?
    public let imagePath: String?
    public let createdAt: Date

    public init(
        id: String,
        title: String,
        recipeDescription: String,
        ingredientsData: Data,
        stepsData: Data,
        preparationTimeMinutes: Int,
        servings: Int,
        nutritionData: Data?,
        imagePath: String?,
        createdAt: Date
    ) {
        self.id = id
        self.title = title
        self.recipeDescription = recipeDescription
        self.ingredientsData = ingredientsData
        self.stepsData = stepsData
        self.preparationTimeMinutes = preparationTimeMinutes
        self.servings = servings
        self.nutritionData = nutritionData
        self.imagePath = imagePath
        self.createdAt = createdAt
    }
}
