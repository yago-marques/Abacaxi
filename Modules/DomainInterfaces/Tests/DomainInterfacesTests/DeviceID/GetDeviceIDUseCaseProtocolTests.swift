import Foundation
import XCTest
@testable import DomainInterfaces

final class GetDeviceIDUseCaseProtocolTests: XCTestCase {
    func test_execute_returnsTheStubbedID() throws {
        let sut = GetDeviceIDUseCaseStub()
        sut.stubbedID = UUID()

        XCTAssertEqual(try sut.execute(), sut.stubbedID)
    }

    func test_execute_withNoStubbedID_returnsNil() throws {
        let sut = GetDeviceIDUseCaseStub()

        XCTAssertNil(try sut.execute())
    }
}
