import DataInterfaces
import DomainInterfaces
import Foundation
import PersistenceInterfaces
import XCTest
@testable import Data

final class SavedRecipeRepositoryTests: XCTestCase {
    func test_fetchAll_returnsSavedRecipesNewestFirst() async throws {
        let store = SavedRecipeStoreStub()
        store.entities = [olderRecipe, newerRecipe]
        let sut = SavedRecipeRepository(persistentStore: store, imageStore: RecipeImageStoreStub())

        let recipes = try await sut.fetchAll()

        XCTAssertEqual(recipes.map(\.id), [newerRecipe.id, olderRecipe.id])
        XCTAssertEqual(recipes.first?.imagePath, "newest.png")
    }

    func test_fetchAll_whenStoreFails_mapsToPersistenceError() async {
        let store = SavedRecipeStoreStub()
        store.fetchAllError = StubbedError.failed
        let sut = SavedRecipeRepository(persistentStore: store, imageStore: RecipeImageStoreStub())

        do {
            _ = try await sut.fetchAll()
            XCTFail("Expected persistence failure")
        } catch {
            XCTAssertEqual(error as? SavedRecipeRepositoryError, .persistenceFailed)
        }
    }

    func test_remove_deletesThePersistedRecipeAndItsImage() async throws {
        let store = SavedRecipeStoreStub()
        store.entities = [newerRecipe]
        let imageStore = RecipeImageStoreStub()
        let sut = SavedRecipeRepository(persistentStore: store, imageStore: imageStore)

        try await sut.remove(id: newerRecipe.id)

        XCTAssertTrue(store.entities.isEmpty)
        XCTAssertEqual(imageStore.deletedNames, ["newest.png"])
    }

    func test_save_thenFetch_roundTripsRecipeWithNutritionAndImage() async throws {
        let store = SavedRecipeStoreStub()
        let sut = SavedRecipeRepository(persistentStore: store, imageStore: RecipeImageStoreStub())
        let recipe = makeBusinessRecipe(
            nutrition: .init(calories: 450, proteinGrams: 12, carbsGrams: 60, fatGrams: 10),
            imageData: Data("imagem".utf8)
        )

        try await sut.save(recipe: recipe)
        let fetched = try await sut.fetch(id: recipe.id.uuidString)

        XCTAssertEqual(fetched, recipe)
    }

    func test_save_thenFetch_withoutNutritionAndImage_roundTripsRecipe() async throws {
        let store = SavedRecipeStoreStub()
        let sut = SavedRecipeRepository(persistentStore: store, imageStore: RecipeImageStoreStub())
        let recipe = makeBusinessRecipe(nutrition: nil, imageData: nil)

        try await sut.save(recipe: recipe)
        let fetched = try await sut.fetch(id: recipe.id.uuidString)

        XCTAssertEqual(fetched, recipe)
        XCTAssertNil(try XCTUnwrap(fetched).nutrition)
        XCTAssertNil(try XCTUnwrap(fetched).imageData)
    }

    func test_save_whenStoreFails_removesNewlyWrittenImage() async {
        let store = SavedRecipeStoreStub()
        store.saveError = StubbedError.failed
        let imageStore = RecipeImageStoreStub()
        let sut = SavedRecipeRepository(persistentStore: store, imageStore: imageStore)
        let recipe = makeBusinessRecipe(nutrition: nil, imageData: Data("image".utf8))

        do {
            try await sut.save(recipe: recipe)
            XCTFail("Expected persistence failure")
        } catch {
            XCTAssertEqual(error as? SavedRecipeRepositoryError, .persistenceFailed)
        }

        XCTAssertEqual(imageStore.deletedNames, ["\(recipe.id.uuidString).png"])
    }

    func test_fetch_whenStoredIDIsNotAValidUUID_throwsPersistenceError() async {
        let store = SavedRecipeStoreStub()
        store.entities = [makeRecipe(id: "not-a-uuid", imagePath: nil, createdAt: .now)]
        let sut = SavedRecipeRepository(persistentStore: store, imageStore: RecipeImageStoreStub())

        do {
            _ = try await sut.fetch(id: "not-a-uuid")
            XCTFail("Expected persistence failure")
        } catch {
            XCTAssertEqual(error as? SavedRecipeRepositoryError, .persistenceFailed)
        }
    }

    func test_fetch_whenRecipeDoesNotExist_returnsNil() async throws {
        let store = SavedRecipeStoreStub()
        let sut = SavedRecipeRepository(persistentStore: store, imageStore: RecipeImageStoreStub())

        let fetchedRecipe = try await sut.fetch(id: UUID().uuidString)
        XCTAssertNil(fetchedRecipe)
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

    func makeBusinessRecipe(nutrition: RecipeNutritionBusinessModel?, imageData: Data?) -> RecipeBusinessModel {
        RecipeBusinessModel(
            title: "Receita",
            description: "Descrição",
            ingredients: [.init(name: "Arroz", quantity: "1 xícara"), .init(name: "Feijão", quantity: "2 conchas")],
            steps: ["Refogue", "Cozinhe"],
            preparationTimeMinutes: 20,
            servings: 2,
            nutrition: nutrition,
            imageData: imageData
        )
    }
}

private final class SavedRecipeStoreStub: PersistentStoringProtocol {
    var entities: [SavedRecipePersistentModel] = []
    var saveError: Error?
    var fetchAllError: Error?

    func save(_ entity: SavedRecipePersistentModel) async throws {
        if let saveError {
            throw saveError
        }
        entities.append(entity)
    }

    func fetch(id: String) async throws -> SavedRecipePersistentModel? {
        entities.first { $0.id == id }
    }

    func fetchAll() async throws -> [SavedRecipePersistentModel] {
        if let fetchAllError {
            throw fetchAllError
        }
        return entities
    }

    func delete(id: String) async throws {
        entities.removeAll { $0.id == id }
    }
}

private final class RecipeImageStoreStub: RecipeImageStoringProtocol {
    private(set) var deletedNames: [String] = []
    private var storedImages: [String: Data] = [:]

    func save(_ data: Data, named name: String) async throws -> String {
        let path = "\(name).png"
        storedImages[path] = data
        return path
    }

    func load(named name: String) async throws -> Data? {
        storedImages[name]
    }

    func delete(named name: String) async throws {
        deletedNames.append(name)
    }
}
