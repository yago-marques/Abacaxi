import XCTest
@testable import Domain

final class GetDeviceIDUseCaseTests: XCTestCase {
    func test_factory_make_returnsAUseCaseConfiguredWithTheRepository() throws {
        let repository = DeviceIDRepositoryStub()
        let id = UUID()
        repository.stubbedLoadResult = id
        let sut = GetDeviceIDUseCaseFactory.make(repository: repository)

        XCTAssertEqual(try sut.execute(), id)
    }

    func test_execute_returnsWhatTheRepositoryLoads() throws {
        let (sut, doubles) = makeSUTAndDoubles()
        let id = UUID()
        doubles.stubbedLoadResult = id

        XCTAssertEqual(try sut.execute(), id)
    }

    func test_execute_withNothingStored_returnsNilWithoutSaving() throws {
        let (sut, doubles) = makeSUTAndDoubles()

        let result = try sut.execute()

        XCTAssertNil(result)
        XCTAssertTrue(doubles.savedIDs.isEmpty)
    }
}

private extension GetDeviceIDUseCaseTests {
    private typealias SUT = GetDeviceIDUseCase
    private typealias Doubles = DeviceIDRepositoryStub

    private func makeSUTAndDoubles() -> (sut: SUT, doubles: Doubles) {
        let repository = DeviceIDRepositoryStub()
        let sut = GetDeviceIDUseCase(repository: repository)
        return (sut, repository)
    }
}
