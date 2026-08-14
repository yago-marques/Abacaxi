import Foundation

public struct RecipeBusinessModel: Equatable, Sendable {
    public let id: UUID
    public let title: String
    public let description: String
    public let ingredients: [RecipeIngredientDetailBusinessModel]
    public let steps: [String]
    public let preparationTimeMinutes: Int
    public let servings: Int
    public let nutrition: RecipeNutritionBusinessModel?
    public let imageData: Data?

    public init(
        id: UUID = UUID(),
        title: String,
        description: String,
        ingredients: [RecipeIngredientDetailBusinessModel],
        steps: [String],
        preparationTimeMinutes: Int,
        servings: Int,
        nutrition: RecipeNutritionBusinessModel?,
        imageData: Data?
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.ingredients = ingredients
        self.steps = steps
        self.preparationTimeMinutes = preparationTimeMinutes
        self.servings = servings
        self.nutrition = nutrition
        self.imageData = imageData
    }
}

public struct RecipeIngredientDetailBusinessModel: Codable, Equatable, Sendable {
    public let name: String
    public let quantity: String

    public init(name: String, quantity: String) {
        self.name = name
        self.quantity = quantity
    }
}

public struct RecipeNutritionBusinessModel: Codable, Equatable, Sendable {
    public let calories: Int
    public let proteinGrams: Int
    public let carbsGrams: Int
    public let fatGrams: Int

    public init(calories: Int, proteinGrams: Int, carbsGrams: Int, fatGrams: Int) {
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbsGrams = carbsGrams
        self.fatGrams = fatGrams
    }
}

public struct RecipeAnswerBusinessModel: Equatable, Sendable {
    public let questionID: String
    public let value: String

    public init(questionID: String, value: String) {
        self.questionID = questionID
        self.value = value
    }
}
