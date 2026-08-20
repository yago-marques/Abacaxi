import DataInterfaces
import DomainInterfaces

final class SavedRecipeRepositoryStub: SavedRecipeRepositoryProtocol {
    var fetchAllResult: Result<[SavedRecipeBusinessModel], Error> = .success([])
    var fetchResult: Result<RecipeBusinessModel?, Error> = .success(nil)
    var removeResult: Result<Void, Error> = .success(())

    func save(recipe: RecipeBusinessModel) async throws {}

    func fetchAll() async throws -> [SavedRecipeBusinessModel] {
        try fetchAllResult.get()
    }

    func fetch(id: String) async throws -> RecipeBusinessModel? {
        try fetchResult.get()
    }

    func remove(id: String) async throws {
        try removeResult.get()
    }
}
