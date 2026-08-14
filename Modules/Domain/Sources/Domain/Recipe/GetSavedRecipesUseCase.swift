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

    public func execute() throws -> [SavedRecipeBusinessModel] {
        do { return try savedRecipeRepository.fetchAll() } catch { throw GetSavedRecipesError.persistenceFailed }
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

    public func execute() throws -> Bool {
        do { return try !savedRecipeRepository.fetchAll().isEmpty } catch { throw GetSavedRecipesError.persistenceFailed }
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

    public func execute(id: String) throws -> RecipeBusinessModel? {
        do {
            return try savedRecipeRepository.fetch(id: id)
        } catch {
            throw GetSavedRecipesError.persistenceFailed
        }
    }
}
