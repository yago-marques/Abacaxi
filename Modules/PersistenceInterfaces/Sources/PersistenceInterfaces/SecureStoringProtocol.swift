import Foundation

public protocol SecureStoringProtocol {
    func save(_ data: Data, forKey key: String) throws
    func read(forKey key: String) throws -> Data?
    func delete(forKey key: String) throws
}
