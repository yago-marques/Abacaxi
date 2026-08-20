import Foundation
import XCTest
@testable import Persistence

final class RecipeImageStoreTests: XCTestCase {
    func test_delete_removesExistingImage() async throws {
        let sut = try RecipeImageStore()
        let name = "RecipeImageStoreTests-\(UUID().uuidString)"
        let savedName = try await sut.save(Data("image".utf8), named: name)

        try await sut.delete(named: savedName)

        let loadedImage = try await sut.load(named: savedName)
        XCTAssertNil(loadedImage)
    }

    func test_delete_withMissingImage_doesNotThrow() async throws {
        let sut = try RecipeImageStore()

        try await sut.delete(named: "missing-\(UUID().uuidString).png")
    }
}
