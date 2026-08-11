import XCTest
@testable import PersistenceInterfaces

final class PersistentStoringTests: XCTestCase {
    func test_saveThenFetch_returnsTheSameEntity() throws {
        let sut = PersistentStoringStub()
        let entity = StubEntity(id: "1")

        try sut.save(entity)

        XCTAssertEqual(try sut.fetch(id: "1")?.id, "1")
    }

    func test_fetchAll_returnsEverySavedEntity() throws {
        let sut = PersistentStoringStub()
        try sut.save(StubEntity(id: "1"))
        try sut.save(StubEntity(id: "2"))

        let all = try sut.fetchAll()

        XCTAssertEqual(Set(all.map(\.id)), ["1", "2"])
    }

    func test_delete_removesTheEntity() throws {
        let sut = PersistentStoringStub()
        try sut.save(StubEntity(id: "1"))

        try sut.delete(id: "1")

        XCTAssertNil(try sut.fetch(id: "1"))
    }
}
