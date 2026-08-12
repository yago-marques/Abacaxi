import XCTest
@testable import DomainInterfaces

final class GetRemainingAttemptsUseCaseProtocolTests: XCTestCase {
    func test_execute_returnsTheStubbedRemainingAttempts() async throws {
        let sut = GetRemainingAttemptsUseCaseStub()
        let expected = RemainingAttempts(remaining: 17, limit: 20, windowSeconds: 3_600)
        sut.stubbedResult = .success(expected)

        let result = try await sut.execute()

        XCTAssertEqual(result, expected)
    }
}
