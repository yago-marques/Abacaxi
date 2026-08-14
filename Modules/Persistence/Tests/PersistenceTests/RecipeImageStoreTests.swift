import Foundation
import XCTest
@testable import Persistence

final class RecipeImageStoreTests: XCTestCase {
    func test_delete_removesExistingImage() throws {
        let sut = try RecipeImageStore()
        let name = "RecipeImageStoreTests-\(UUID().uuidString)"
        let savedName = try sut.save(Data("image".utf8), named: name)

        try sut.delete(named: savedName)

        XCTAssertNil(try sut.load(named: savedName))
    }

    func test_delete_withMissingImage_doesNotThrow() throws {
        let sut = try RecipeImageStore()

        XCTAssertNoThrow(try sut.delete(named: "missing-\(UUID().uuidString).png"))
    }
}
