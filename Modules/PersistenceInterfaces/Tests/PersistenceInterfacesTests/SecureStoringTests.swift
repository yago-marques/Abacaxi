import Foundation
import XCTest
@testable import PersistenceInterfaces

final class SecureStoringTests: XCTestCase {
    func test_saveThenRead_returnsTheSameData() throws {
        let sut = SecureStoringStub()
        let data = Data("secret".utf8)

        try sut.save(data, forKey: "token")

        XCTAssertEqual(try sut.read(forKey: "token"), data)
    }

    func test_delete_removesPreviouslySavedData() throws {
        let sut = SecureStoringStub()
        try sut.save(Data("secret".utf8), forKey: "token")

        try sut.delete(forKey: "token")

        XCTAssertNil(try sut.read(forKey: "token"))
    }
}
