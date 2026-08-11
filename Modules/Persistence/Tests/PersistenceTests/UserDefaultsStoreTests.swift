import XCTest
@testable import Persistence

final class UserDefaultsStoreTests: XCTestCase {
    func test_setThenValue_returnsTheSameValue() {
        let (sut, _) = makeSUT()

        sut.set("hello", forKey: "greeting")

        XCTAssertEqual(sut.value(forKey: "greeting"), "hello")
    }

    func test_value_withNoStoredValue_returnsNil() {
        let (sut, _) = makeSUT()

        let value: String? = sut.value(forKey: "missing")

        XCTAssertNil(value)
    }

    func test_removeValue_clearsPreviouslySetValue() {
        let (sut, _) = makeSUT()
        sut.set("hello", forKey: "greeting")

        sut.removeValue(forKey: "greeting")

        let value: String? = sut.value(forKey: "greeting")
        XCTAssertNil(value)
    }
}

private extension UserDefaultsStoreTests {
    func makeSUT() -> (sut: UserDefaultsStore, suiteName: String) {
        let suiteName = "UserDefaultsStoreTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        addTeardownBlock {
            defaults.removePersistentDomain(forName: suiteName)
        }
        return (UserDefaultsStore(defaults: defaults), suiteName)
    }
}
