import Foundation
import PersistenceInterfaces

public enum RecipeImageStoreError: Error {
    case documentsDirectoryUnavailable
}

public actor RecipeImageStore: RecipeImageStoringProtocol {
    private let fileManager: FileManager
    private let directoryURL: URL

    public init(fileManager: FileManager = .default) throws {
        self.fileManager = fileManager
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw RecipeImageStoreError.documentsDirectoryUnavailable
        }
        directoryURL = documentsURL.appendingPathComponent("RecipeImages", isDirectory: true)
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }

    public func save(_ data: Data, named name: String) async throws -> String {
        let fileName = "\(name).png"
        let fileURL = directoryURL.appendingPathComponent(fileName)
        try data.write(to: fileURL, options: .atomic)
        return fileName
    }

    public func load(named name: String) async throws -> Data? {
        let fileURL = directoryURL.appendingPathComponent(name)
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        return try Data(contentsOf: fileURL)
    }

    public func delete(named name: String) async throws {
        let fileURL = directoryURL.appendingPathComponent(name)
        guard fileManager.fileExists(atPath: fileURL.path) else { return }

        try fileManager.removeItem(at: fileURL)
    }
}
