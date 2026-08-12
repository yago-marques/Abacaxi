import XCTest
@testable import Data

final class DeviceIDRepositoryTests: XCTestCase {
    func test_factory_make_returnsARepositoryConfiguredWithTheSecureStore() throws {
        let secureStoring = SecureStoringStub()
        let sut = DeviceIDRepositoryFactory.make(secureStoring: secureStoring)
        let id = UUID()

        try sut.save(id)

        XCTAssertEqual(try sut.load(), id)
    }

    func test_saveThenLoad_returnsTheSameID() throws {
        let (sut, _) = makeSUTAndDoubles()
        let id = UUID()

        try sut.save(id)

        XCTAssertEqual(try sut.load(), id)
    }

    func test_load_withNothingSaved_returnsNil() throws {
        let (sut, _) = makeSUTAndDoubles()

        XCTAssertNil(try sut.load())
    }

    func test_load_withANewInstanceSharingTheSameStore_returnsThePersistedID() throws {
        let (sut, doubles) = makeSUTAndDoubles()
        let id = UUID()
        try sut.save(id)

        let otherRepository = DeviceIDRepository(secureStoring: doubles)

        XCTAssertEqual(try otherRepository.load(), id)
    }
}

private extension DeviceIDRepositoryTests {
    private typealias SUT = DeviceIDRepository
    private typealias Doubles = SecureStoringStub

    private func makeSUTAndDoubles() -> (sut: SUT, doubles: Doubles) {
        let secureStoring = SecureStoringStub()
        let sut = DeviceIDRepository(secureStoring: secureStoring)
        return (sut, secureStoring)
    }
}
