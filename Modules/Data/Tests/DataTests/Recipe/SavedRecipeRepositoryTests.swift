import DataInterfaces
import DomainInterfaces
import Foundation
import PersistenceInterfaces
import XCTest
@testable import Data

final class SavedRecipeRepositoryTests: XCTestCase {
    func test_fetchAll_returnsSavedRecipesNewestFirst() throws {
        let store = SavedRecipeStoreStub()
        store.entities = [olderRecipe, newerRecipe]
        let sut = SavedRecipeRepository(persistentStore: store, imageStore: RecipeImageStoreStub())

        let recipes = try sut.fetchAll()

        XCTAssertEqual(recipes.map(\.id), [newerRecipe.id, olderRecipe.id])
        XCTAssertEqual(recipes.first?.imagePath, "newest.png")
    }

    func test_fetchAll_whenStoreFails_mapsToPersistenceError() {
        let store = SavedRecipeStoreStub()
        store.fetchAllError = StubbedError.failed
        let sut = SavedRecipeRepository(persistentStore: store, imageStore: RecipeImageStoreStub())

        XCTAssertThrowsError(try sut.fetchAll()) { error in
            XCTAssertEqual(error as? SavedRecipeRepositoryError, .persistenceFailed)
        }
    }

    func test_remove_deletesThePersistedRecipeAndItsImage() throws {
        let store = SavedRecipeStoreStub()
        store.entities = [newerRecipe]
        let imageStore = RecipeImageStoreStub()
        let sut = SavedRecipeRepository(persistentStore: store, imageStore: imageStore)

        try sut.remove(id: newerRecipe.id)

        XCTAssertTrue(store.entities.isEmpty)
        XCTAssertEqual(imageStore.deletedNames, ["newest.png"])
    }
}

private extension SavedRecipeRepositoryTests {
    enum StubbedError: Error {
        case failed
    }

    var olderRecipe: SavedRecipePersistentModel {
        makeRecipe(id: "older", imagePath: nil, createdAt: .distantPast)
    }

    var newerRecipe: SavedRecipePersistentModel {
        makeRecipe(id: "newer", imagePath: "newest.png", createdAt: .now)
    }

    func makeRecipe(id: String, imagePath: String?, createdAt: Date) -> SavedRecipePersistentModel {
        SavedRecipePersistentModel(
            id: id,
            title: "Receita",
            recipeDescription: "Descrição",
            ingredientsData: Data(),
            stepsData: Data(),
            preparationTimeMinutes: 20,
            servings: 2,
            nutritionData: nil,
            imagePath: imagePath,
            createdAt: createdAt
        )
    }
}

private final class SavedRecipeStoreStub: PersistentStoringProtocol {
    var entities: [SavedRecipePersistentModel] = []
    var fetchAllError: Error?

    func save(_ entity: SavedRecipePersistentModel) throws {
        entities.append(entity)
    }

    func fetch(id: String) throws -> SavedRecipePersistentModel? {
        entities.first { $0.id == id }
    }

    func fetchAll() throws -> [SavedRecipePersistentModel] {
        if let fetchAllError {
            throw fetchAllError
        }
        return entities
    }

    func delete(id: String) throws {
        entities.removeAll { $0.id == id }
    }
}

private final class RecipeImageStoreStub: RecipeImageStoringProtocol {
    private(set) var deletedNames: [String] = []

    func save(_ data: Data, named name: String) throws -> String {
        "\(name).png"
    }

    func load(named name: String) throws -> Data? {
        nil
    }

    func delete(named name: String) throws {
        deletedNames.append(name)
    }
}
