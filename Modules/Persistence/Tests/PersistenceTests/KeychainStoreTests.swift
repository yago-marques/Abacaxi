import XCTest
@testable import Persistence

final class KeychainStoreTests: XCTestCase {
    func test_saveThenRead_returnsTheSameData() throws {
        let sut = try makeSUT()
        let key = uniqueKey()
        let data = Data("secret".utf8)

        try sut.save(data, forKey: key)

        XCTAssertEqual(try sut.read(forKey: key), data)
    }

    func test_read_withNothingSaved_returnsNil() throws {
        let sut = try makeSUT()

        XCTAssertNil(try sut.read(forKey: uniqueKey()))
    }

    func test_delete_removesPreviouslySavedData() throws {
        let sut = try makeSUT()
        let key = uniqueKey()
        try sut.save(Data("secret".utf8), forKey: key)

        try sut.delete(forKey: key)

        XCTAssertNil(try sut.read(forKey: key))
    }

    func test_save_overwritesExistingValueForSameKey() throws {
        let sut = try makeSUT()
        let key = uniqueKey()
        try sut.save(Data("first".utf8), forKey: key)

        try sut.save(Data("second".utf8), forKey: key)

        XCTAssertEqual(try sut.read(forKey: key), Data("second".utf8))
    }
}

private extension KeychainStoreTests {
    func makeSUT() throws -> KeychainStore {
        try KeychainStore(service: "KeychainStoreTests")
    }

    func uniqueKey() -> String {
        UUID().uuidString
    }
}
