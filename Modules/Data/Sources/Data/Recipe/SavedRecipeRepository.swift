import DataInterfaces
import DomainInterfaces
import Foundation
import PersistenceInterfaces

public enum SavedRecipeRepositoryFactory {
    public static func make<Store: PersistentStoringProtocol>(
        persistentStore: Store,
        imageStore: RecipeImageStoringProtocol
    ) -> SavedRecipeRepositoryProtocol where Store.Entity == SavedRecipePersistentModel {
        SavedRecipeRepository(persistentStore: persistentStore, imageStore: imageStore)
    }
}

public final class SavedRecipeRepository<Store: PersistentStoringProtocol>: SavedRecipeRepositoryProtocol
where Store.Entity == SavedRecipePersistentModel {
    private let persistentStore: Store
    private let imageStore: RecipeImageStoringProtocol

    public init(
        persistentStore: Store,
        imageStore: RecipeImageStoringProtocol
    ) {
        self.persistentStore = persistentStore
        self.imageStore = imageStore
    }

    public func save(recipe: RecipeBusinessModel) async throws {
        do {
            let model = try await SavedRecipePersistentModel(recipe: recipe, imageStore: imageStore)
            do {
                try await persistentStore.save(model)
            } catch {
                if let imagePath = model.imagePath {
                    // Best effort: preserve the original persistence error.
                    try? await imageStore.delete(named: imagePath)
                }
                throw error
            }
        } catch {
            throw SavedRecipeRepositoryError.persistenceFailed
        }
    }

    public func fetchAll() async throws -> [SavedRecipeBusinessModel] {
        do {
            return try await persistentStore.fetchAll()
                .sorted { $0.createdAt > $1.createdAt }
                .map(SavedRecipeBusinessModel.init)
        } catch {
            throw SavedRecipeRepositoryError.persistenceFailed
        }
    }

    public func fetch(id: String) async throws -> RecipeBusinessModel? {
        do {
            guard let model = try await persistentStore.fetch(id: id) else { return nil }
            return try await RecipeBusinessModel(model, imageStore: imageStore)
        } catch {
            throw SavedRecipeRepositoryError.persistenceFailed
        }
    }

    public func remove(id: String) async throws {
        do {
            let savedRecipe = try await persistentStore.fetch(id: id)
            try await persistentStore.delete(id: id)
            if let imagePath = savedRecipe?.imagePath {
                try await imageStore.delete(named: imagePath)
            }
        } catch {
            throw SavedRecipeRepositoryError.persistenceFailed
        }
    }
}

private extension SavedRecipeBusinessModel {
    init(_ model: SavedRecipePersistentModel) {
        self.init(
            id: model.id,
            title: model.title,
            description: model.recipeDescription,
            preparationTimeMinutes: model.preparationTimeMinutes,
            servings: model.servings,
            imagePath: model.imagePath
        )
    }
}

private extension SavedRecipePersistentModel {
    init(recipe: RecipeBusinessModel, imageStore: RecipeImageStoringProtocol) async throws {
        id = recipe.id.uuidString
        title = recipe.title
        recipeDescription = recipe.description
        ingredientsData = try JSONEncoder().encode(recipe.ingredients.map(RecipeIngredientPersistentDTO.init))
        stepsData = try JSONEncoder().encode(recipe.steps)
        preparationTimeMinutes = recipe.preparationTimeMinutes
        servings = recipe.servings
        nutritionData = try recipe.nutrition.map { try JSONEncoder().encode(RecipeNutritionPersistentDTO($0)) }
        if let imageData = recipe.imageData {
            imagePath = try await imageStore.save(imageData, named: recipe.id.uuidString)
        } else {
            imagePath = nil
        }
        createdAt = Date()
    }
}

private extension RecipeBusinessModel {
    init(_ model: SavedRecipePersistentModel, imageStore: RecipeImageStoringProtocol) async throws {
        guard let id = UUID(uuidString: model.id) else {
            throw SavedRecipeRepositoryError.persistenceFailed
        }

        self.init(
            id: id,
            title: model.title,
            description: model.recipeDescription,
            ingredients: try JSONDecoder().decode(
                [RecipeIngredientPersistentDTO].self,
                from: model.ingredientsData
            ).map(RecipeIngredientDetailBusinessModel.init),
            steps: try JSONDecoder().decode([String].self, from: model.stepsData),
            preparationTimeMinutes: model.preparationTimeMinutes,
            servings: model.servings,
            nutrition: try model.nutritionData.map {
                RecipeNutritionBusinessModel(try JSONDecoder().decode(RecipeNutritionPersistentDTO.self, from: $0))
            },
            imageData: try await Self.imageData(from: model.imagePath, imageStore: imageStore)
        )
    }

    private static func imageData(
        from imagePath: String?,
        imageStore: RecipeImageStoringProtocol
    ) async throws -> Data? {
        guard let imagePath else { return nil }
        return try await imageStore.load(named: imagePath)
    }
}
