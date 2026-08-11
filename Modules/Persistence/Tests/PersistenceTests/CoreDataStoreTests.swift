import XCTest
@testable import Persistence

final class CoreDataStoreTests: XCTestCase {
    func test_saveThenFetch_returnsTheSameEntity() throws {
        let sut = TestItemModel.makeStore()
        let item = TestItem(id: "1", name: "first")

        try sut.save(item)

        XCTAssertEqual(try sut.fetch(id: "1"), item)
    }

    func test_fetch_withNothingSaved_returnsNil() throws {
        let sut = TestItemModel.makeStore()

        XCTAssertNil(try sut.fetch(id: "missing"))
    }

    func test_save_withExistingID_updatesInPlaceInsteadOfDuplicating() throws {
        let sut = TestItemModel.makeStore()
        try sut.save(TestItem(id: "1", name: "first"))

        try sut.save(TestItem(id: "1", name: "updated"))

        XCTAssertEqual(try sut.fetch(id: "1")?.name, "updated")
        XCTAssertEqual(try sut.fetchAll().count, 1)
    }

    func test_fetchAll_returnsEverySavedEntity() throws {
        let sut = TestItemModel.makeStore()
        try sut.save(TestItem(id: "1", name: "first"))
        try sut.save(TestItem(id: "2", name: "second"))

        let all = try sut.fetchAll()

        XCTAssertEqual(Set(all.map(\.id)), ["1", "2"])
    }

    func test_delete_removesTheEntity() throws {
        let sut = TestItemModel.makeStore()
        try sut.save(TestItem(id: "1", name: "first"))

        try sut.delete(id: "1")

        XCTAssertNil(try sut.fetch(id: "1"))
    }

    func test_delete_withNothingSaved_doesNotThrow() throws {
        let sut = TestItemModel.makeStore()

        try sut.delete(id: "missing")
    }
}
