import DataInterfaces
import DomainInterfaces
import XCTest
@testable import Domain

final class GetSavedRecipesUseCaseTests: XCTestCase {
    func test_execute_whenRepositoryReturnsRecipes_returnsRecipes() throws {
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

        let recipes = try sut.execute()

        XCTAssertEqual(recipes, [expected])
    }

    func test_execute_whenRepositoryReturnsEmptyCollection_returnsEmptyCollection() throws {
        let sut = GetSavedRecipesUseCase(savedRecipeRepository: SavedRecipeRepositoryStub())

        XCTAssertTrue(try sut.execute().isEmpty)
    }

    func test_execute_whenRepositoryFails_mapsToPersistenceError() {
        let repository = SavedRecipeRepositoryStub()
        repository.fetchAllResult = .failure(SavedRecipeRepositoryError.persistenceFailed)
        let sut = GetSavedRecipesUseCase(savedRecipeRepository: repository)

        XCTAssertThrowsError(try sut.execute()) { error in
            XCTAssertEqual(error as? GetSavedRecipesError, .persistenceFailed)
        }
    }

    func test_hasSavedRecipes_whenRepositoryReturnsRecipes_returnsTrue() throws {
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

        XCTAssertTrue(try sut.execute())
    }

    func test_remove_whenRepositorySucceeds_completes() throws {
        let sut = RemoveSavedRecipeUseCase(savedRecipeRepository: SavedRecipeRepositoryStub())

        XCTAssertNoThrow(try sut.execute(id: "1"))
    }

    func test_remove_whenRepositoryFails_mapsToPersistenceError() {
        let repository = SavedRecipeRepositoryStub()
        repository.removeResult = .failure(SavedRecipeRepositoryError.persistenceFailed)
        let sut = RemoveSavedRecipeUseCase(savedRecipeRepository: repository)

        XCTAssertThrowsError(try sut.execute(id: "1")) { error in
            XCTAssertEqual(error as? RemoveSavedRecipeError, .persistenceFailed)
        }
    }
}
