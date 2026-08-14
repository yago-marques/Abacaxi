import DataInterfaces
import DomainInterfaces

final class SavedRecipeRepositoryStub: SavedRecipeRepositoryProtocol {
    var fetchAllResult: Result<[SavedRecipeBusinessModel], Error> = .success([])
    var fetchResult: Result<RecipeBusinessModel?, Error> = .success(nil)
    var removeResult: Result<Void, Error> = .success(())

    func save(recipe: RecipeBusinessModel) throws {}

    func fetchAll() throws -> [SavedRecipeBusinessModel] {
        try fetchAllResult.get()
    }

    func fetch(id: String) throws -> RecipeBusinessModel? {
        try fetchResult.get()
    }

    func remove(id: String) throws {
        try removeResult.get()
    }
}
