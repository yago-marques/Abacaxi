import Foundation

public struct SavedRecipeBusinessModel: Equatable, Sendable, Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let preparationTimeMinutes: Int
    public let servings: Int
    public let imagePath: String?

    public init(
        id: String,
        title: String,
        description: String,
        preparationTimeMinutes: Int,
        servings: Int,
        imagePath: String?
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.preparationTimeMinutes = preparationTimeMinutes
        self.servings = servings
        self.imagePath = imagePath
    }
}
