import DomainInterfaces
import Foundation

struct SavedRecipePresentationModel: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let preparationTimeMinutes: Int
    let servings: Int
    let imageURL: URL?

    init(_ model: SavedRecipeBusinessModel) {
        id = model.id
        title = model.title
        description = model.description
        preparationTimeMinutes = model.preparationTimeMinutes
        servings = model.servings
        imageURL = Self.makeImageURL(from: model.imagePath)
    }

    private static func makeImageURL(from path: String?) -> URL? {
        guard let path else { return nil }

        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("RecipeImages", isDirectory: true)
            .appendingPathComponent(path)
    }
}
