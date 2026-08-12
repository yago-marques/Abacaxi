import Foundation
import XCTest
@testable import DataInterfaces

final class DeviceIDRepositoryProtocolTests: XCTestCase {
    func test_saveThenLoad_returnsTheSameID() throws {
        let sut = DeviceIDRepositoryStub()
        let id = UUID()

        try sut.save(id)

        XCTAssertEqual(try sut.load(), id)
    }

    func test_load_withNothingSaved_returnsNil() throws {
        let sut = DeviceIDRepositoryStub()

        XCTAssertNil(try sut.load())
    }
}
