import Foundation

public protocol RecipeImageStoringProtocol {
    func save(_ data: Data, named name: String) throws -> String
    func load(named name: String) throws -> Data?
    func delete(named name: String) throws
}
