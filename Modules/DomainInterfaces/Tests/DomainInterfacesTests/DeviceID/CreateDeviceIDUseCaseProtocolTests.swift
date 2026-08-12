import Foundation
import XCTest
@testable import DomainInterfaces

final class CreateDeviceIDUseCaseProtocolTests: XCTestCase {
    func test_execute_returnsTheStubbedID() throws {
        let sut = CreateDeviceIDUseCaseStub()

        XCTAssertEqual(try sut.execute(), sut.stubbedID)
    }
}
