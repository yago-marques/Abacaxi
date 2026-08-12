import XCTest
@testable import Domain

final class CreateDeviceIDUseCaseTests: XCTestCase {
    func test_factory_make_returnsAUseCaseConfiguredWithTheRepository() throws {
        let repository = DeviceIDRepositoryStub()
        let sut = CreateDeviceIDUseCaseFactory.make(repository: repository)

        let id = try sut.execute()

        XCTAssertEqual(repository.savedIDs, [id])
    }

    func test_execute_savesTheGeneratedIDAndReturnsIt() throws {
        let (sut, doubles) = makeSUTAndDoubles()

        let id = try sut.execute()

        XCTAssertEqual(doubles.savedIDs, [id])
    }

    func test_execute_calledTwice_alwaysSavesAFreshID() throws {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.stubbedLoadResult = UUID()

        let firstID = try sut.execute()
        let secondID = try sut.execute()

        XCTAssertNotEqual(firstID, secondID)
        XCTAssertEqual(doubles.savedIDs, [firstID, secondID])
    }
}

private extension CreateDeviceIDUseCaseTests {
    private typealias SUT = CreateDeviceIDUseCase
    private typealias Doubles = DeviceIDRepositoryStub

    private func makeSUTAndDoubles() -> (sut: SUT, doubles: Doubles) {
        let repository = DeviceIDRepositoryStub()
        let sut = CreateDeviceIDUseCase(repository: repository)
        return (sut, repository)
    }
}
