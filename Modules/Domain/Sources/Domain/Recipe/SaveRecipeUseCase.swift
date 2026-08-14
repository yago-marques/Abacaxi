import DataInterfaces
import DomainInterfaces

public enum SaveRecipeUseCaseFactory {
    public static func make(savedRecipeRepository: SavedRecipeRepositoryProtocol) -> SaveRecipeUseCaseProtocol {
        SaveRecipeUseCase(savedRecipeRepository: savedRecipeRepository)
    }
}

public final class SaveRecipeUseCase: SaveRecipeUseCaseProtocol {
    private let savedRecipeRepository: SavedRecipeRepositoryProtocol

    public init(savedRecipeRepository: SavedRecipeRepositoryProtocol) {
        self.savedRecipeRepository = savedRecipeRepository
    }

    public func execute(recipe: RecipeBusinessModel) throws {
        do {
            try savedRecipeRepository.save(recipe: recipe)
        } catch {
            throw SaveRecipeError.persistenceFailed
        }
    }
}

public enum RemoveSavedRecipeUseCaseFactory {
    public static func make(savedRecipeRepository: SavedRecipeRepositoryProtocol) -> RemoveSavedRecipeUseCaseProtocol {
        RemoveSavedRecipeUseCase(savedRecipeRepository: savedRecipeRepository)
    }
}

public final class RemoveSavedRecipeUseCase: RemoveSavedRecipeUseCaseProtocol {
    private let savedRecipeRepository: SavedRecipeRepositoryProtocol

    public init(savedRecipeRepository: SavedRecipeRepositoryProtocol) {
        self.savedRecipeRepository = savedRecipeRepository
    }

    public func execute(id: String) throws {
        do {
            try savedRecipeRepository.remove(id: id)
        } catch {
            throw RemoveSavedRecipeError.persistenceFailed
        }
    }
}
