import DataInterfaces
import DomainInterfaces
import XCTest
@testable import Domain

final class GetSavedRecipesUseCaseTests: XCTestCase {
    func test_execute_whenRepositoryReturnsRecipes_returnsRecipes() async throws {
        let repository = SavedRecipeRepositoryStub()
        let expected = SavedRecipeBusinessModel(
            id: "1",
            title: "Macarrão",
            description: "Receita simples",
            preparationTimeMinutes: 20,
            servings: 2,
            imagePath: nil
        )
        repository.fetchAllResult = .success([expected])
        let sut = GetSavedRecipesUseCase(savedRecipeRepository: repository)

        let recipes = try await sut.execute()

        XCTAssertEqual(recipes, [expected])
    }

    func test_execute_whenRepositoryReturnsEmptyCollection_returnsEmptyCollection() async throws {
        let sut = GetSavedRecipesUseCase(savedRecipeRepository: SavedRecipeRepositoryStub())

        let recipes = try await sut.execute()
        XCTAssertTrue(recipes.isEmpty)
    }

    func test_execute_whenRepositoryFails_mapsToPersistenceError() async {
        let repository = SavedRecipeRepositoryStub()
        repository.fetchAllResult = .failure(SavedRecipeRepositoryError.persistenceFailed)
        let sut = GetSavedRecipesUseCase(savedRecipeRepository: repository)

        do {
            _ = try await sut.execute()
            XCTFail("Expected persistence failure")
        } catch {
            XCTAssertEqual(error as? GetSavedRecipesError, .persistenceFailed)
        }
    }

    func test_hasSavedRecipes_whenRepositoryReturnsRecipes_returnsTrue() async throws {
        let repository = SavedRecipeRepositoryStub()
        repository.fetchAllResult = .success([
            SavedRecipeBusinessModel(
                id: "1",
                title: "Macarrão",
                description: "Receita simples",
                preparationTimeMinutes: 20,
                servings: 2,
                imagePath: nil
            )
        ])
        let sut = HasSavedRecipesUseCase(savedRecipeRepository: repository)

        let hasSavedRecipes = try await sut.execute()
        XCTAssertTrue(hasSavedRecipes)
    }

    func test_remove_whenRepositorySucceeds_completes() async throws {
        let sut = RemoveSavedRecipeUseCase(savedRecipeRepository: SavedRecipeRepositoryStub())

        try await sut.execute(id: "1")
    }

    func test_remove_whenRepositoryFails_mapsToPersistenceError() async {
        let repository = SavedRecipeRepositoryStub()
        repository.removeResult = .failure(SavedRecipeRepositoryError.persistenceFailed)
        let sut = RemoveSavedRecipeUseCase(savedRecipeRepository: repository)

        do {
            try await sut.execute(id: "1")
            XCTFail("Expected persistence failure")
        } catch {
            XCTAssertEqual(error as? RemoveSavedRecipeError, .persistenceFailed)
        }
    }
}
