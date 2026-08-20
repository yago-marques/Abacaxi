import DataInterfaces
import DomainInterfaces

public enum GetSavedRecipesUseCaseFactory {
    public static func make(savedRecipeRepository: SavedRecipeRepositoryProtocol) -> GetSavedRecipesUseCaseProtocol {
        GetSavedRecipesUseCase(savedRecipeRepository: savedRecipeRepository)
    }
}

public final class GetSavedRecipesUseCase: GetSavedRecipesUseCaseProtocol {
    private let savedRecipeRepository: SavedRecipeRepositoryProtocol

    public init(savedRecipeRepository: SavedRecipeRepositoryProtocol) {
        self.savedRecipeRepository = savedRecipeRepository
    }

    public func execute() async throws -> [SavedRecipeBusinessModel] {
        do { return try await savedRecipeRepository.fetchAll() } catch { throw GetSavedRecipesError.persistenceFailed }
    }
}

public enum HasSavedRecipesUseCaseFactory {
    public static func make(savedRecipeRepository: SavedRecipeRepositoryProtocol) -> HasSavedRecipesUseCaseProtocol {
        HasSavedRecipesUseCase(savedRecipeRepository: savedRecipeRepository)
    }
}

public final class HasSavedRecipesUseCase: HasSavedRecipesUseCaseProtocol {
    private let savedRecipeRepository: SavedRecipeRepositoryProtocol

    public init(savedRecipeRepository: SavedRecipeRepositoryProtocol) {
        self.savedRecipeRepository = savedRecipeRepository
    }

    public func execute() async throws -> Bool {
        do {
            let recipes = try await savedRecipeRepository.fetchAll()
            return !recipes.isEmpty
        } catch {
            throw GetSavedRecipesError.persistenceFailed
        }
    }
}

public enum GetSavedRecipeUseCaseFactory {
    public static func make(savedRecipeRepository: SavedRecipeRepositoryProtocol) -> GetSavedRecipeUseCaseProtocol {
        GetSavedRecipeUseCase(savedRecipeRepository: savedRecipeRepository)
    }
}

public final class GetSavedRecipeUseCase: GetSavedRecipeUseCaseProtocol {
    private let savedRecipeRepository: SavedRecipeRepositoryProtocol

    public init(savedRecipeRepository: SavedRecipeRepositoryProtocol) {
        self.savedRecipeRepository = savedRecipeRepository
    }

    public func execute(id: String) async throws -> RecipeBusinessModel? {
        do {
            return try await savedRecipeRepository.fetch(id: id)
        } catch {
            throw GetSavedRecipesError.persistenceFailed
        }
    }
}
