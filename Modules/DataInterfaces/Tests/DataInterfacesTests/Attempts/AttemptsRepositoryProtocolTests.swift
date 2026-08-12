import Foundation
import XCTest
@testable import DataInterfaces

final class AttemptsRepositoryProtocolTests: XCTestCase {
    func test_fetchAttempts_returnsTheStubbedResponseForTheReceivedDeviceID() async throws {
        let sut = AttemptsRepositoryStub()
        let deviceID = UUID()
        let response = AttemptsResponse(remaining: 17, limit: 20, windowSeconds: 3_600)
        sut.stubbedResult = .success(response)

        let result = try await sut.fetchAttempts(deviceID: deviceID)

        XCTAssertEqual(result, response)
        XCTAssertEqual(sut.receivedDeviceIDs, [deviceID])
    }
}
