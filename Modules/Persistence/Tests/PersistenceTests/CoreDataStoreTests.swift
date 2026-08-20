import XCTest
@testable import Persistence

final class CoreDataStoreTests: XCTestCase {
    func test_saveThenFetch_returnsTheSameEntity() async throws {
        let sut = TestItemModel.makeStore()
        let item = TestItemMock(id: "1", name: "first")

        try await sut.save(item)

        let fetchedItem = try await sut.fetch(id: "1")
        XCTAssertEqual(fetchedItem, item)
    }

    func test_fetch_withNothingSaved_returnsNil() async throws {
        let sut = TestItemModel.makeStore()

        let fetchedItem = try await sut.fetch(id: "missing")
        XCTAssertNil(fetchedItem)
    }

    func test_save_withExistingID_updatesInPlaceInsteadOfDuplicating() async throws {
        let sut = TestItemModel.makeStore()
        try await sut.save(TestItemMock(id: "1", name: "first"))

        try await sut.save(TestItemMock(id: "1", name: "updated"))

        let updatedItem = try await sut.fetch(id: "1")
        let allItems = try await sut.fetchAll()
        XCTAssertEqual(updatedItem?.name, "updated")
        XCTAssertEqual(allItems.count, 1)
    }

    func test_fetchAll_returnsEverySavedEntity() async throws {
        let sut = TestItemModel.makeStore()
        try await sut.save(TestItemMock(id: "1", name: "first"))
        try await sut.save(TestItemMock(id: "2", name: "second"))

        let all = try await sut.fetchAll()

        XCTAssertEqual(Set(all.map(\.id)), ["1", "2"])
    }

    func test_delete_removesTheEntity() async throws {
        let sut = TestItemModel.makeStore()
        try await sut.save(TestItemMock(id: "1", name: "first"))

        try await sut.delete(id: "1")

        let fetchedItem = try await sut.fetch(id: "1")
        XCTAssertNil(fetchedItem)
    }

    func test_delete_withNothingSaved_doesNotThrow() async throws {
        let sut = TestItemModel.makeStore()

        try await sut.delete(id: "missing")
    }
}
