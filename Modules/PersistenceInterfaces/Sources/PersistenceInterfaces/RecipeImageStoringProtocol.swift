import Foundation

public protocol RecipeImageStoringProtocol {
    func save(_ data: Data, named name: String) async throws -> String
    func load(named name: String) async throws -> Data?
    func delete(named name: String) async throws
}
