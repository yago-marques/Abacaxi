import XCTest
@testable import PersistenceInterfaces

final class KeyValueStoringTests: XCTestCase {
    func test_setThenValue_returnsTheSameValue() {
        let sut = KeyValueStoringStub()

        sut.set("hello", forKey: "greeting")

        XCTAssertEqual(sut.value(forKey: "greeting"), "hello")
    }

    func test_removeValue_clearsPreviouslySetValue() {
        let sut = KeyValueStoringStub()
        sut.set("hello", forKey: "greeting")

        sut.removeValue(forKey: "greeting")

        let value: String? = sut.value(forKey: "greeting")
        XCTAssertNil(value)
    }
}
