import XCTest
@testable import PersistenceInterfaces

final class PersistentStoringTests: XCTestCase {
    func test_saveThenFetch_returnsTheSameEntity() async throws {
        let sut = PersistentStoringStub()
        let entity = StubEntity(id: "1")

        try await sut.save(entity)

        let fetchedID = try await sut.fetch(id: "1")?.id
        XCTAssertEqual(fetchedID, "1")
    }

    func test_fetchAll_returnsEverySavedEntity() async throws {
        let sut = PersistentStoringStub()
        try await sut.save(StubEntity(id: "1"))
        try await sut.save(StubEntity(id: "2"))

        let all = try await sut.fetchAll()

        XCTAssertEqual(Set(all.map(\.id)), ["1", "2"])
    }

    func test_delete_removesTheEntity() async throws {
        let sut = PersistentStoringStub()
        try await sut.save(StubEntity(id: "1"))

        try await sut.delete(id: "1")

        let fetchedEntity = try await sut.fetch(id: "1")
        XCTAssertNil(fetchedEntity)
    }
}
