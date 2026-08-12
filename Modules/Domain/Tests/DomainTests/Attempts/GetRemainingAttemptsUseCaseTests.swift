import DataInterfaces
import DomainInterfaces
import Foundation
import XCTest
@testable import Domain

final class GetRemainingAttemptsUseCaseTests: XCTestCase {
    func test_factory_make_returnsAUseCaseConfiguredWithRepositories() async throws {
        let deviceIDRepository = DeviceIDRepositoryStub()
        let attemptsRepository = AttemptsRepositoryStub()
        let deviceID = UUID()
        deviceIDRepository.stubbedLoadResult = deviceID
        attemptsRepository.stubbedResult = .success(AttemptsResponse(remaining: 17, limit: 20, windowSeconds: 3_600))
        let sut = GetRemainingAttemptsUseCaseFactory.make(
            deviceIDRepository: deviceIDRepository,
            attemptsRepository: attemptsRepository
        )

        let result = try await sut.execute()

        XCTAssertEqual(result, RemainingAttempts(remaining: 17, limit: 20, windowSeconds: 3_600))
    }

    func test_execute_mapsTheAttemptsResponse() async throws {
        let (sut, doubles) = makeSUTAndDoubles()
        let deviceID = UUID()
        doubles.deviceIDRepository.stubbedLoadResult = deviceID
        doubles.attemptsRepository.stubbedResult = .success(
            AttemptsResponse(remaining: 17, limit: 20, windowSeconds: 3_600)
        )

        let result = try await sut.execute()

        XCTAssertEqual(result, RemainingAttempts(remaining: 17, limit: 20, windowSeconds: 3_600))
        XCTAssertEqual(doubles.attemptsRepository.receivedDeviceIDs, [deviceID])
    }

    func test_execute_propagatesTheAttemptsRepositoryFailure() async {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.deviceIDRepository.stubbedLoadResult = UUID()
        let expectedError = NSError(domain: "GetRemainingAttemptsUseCaseTests", code: 1)
        doubles.attemptsRepository.stubbedResult = .failure(expectedError)

        do {
            _ = try await sut.execute()
            XCTFail("Expected an error")
        } catch {
            XCTAssertEqual((error as NSError).domain, expectedError.domain)
            XCTAssertEqual((error as NSError).code, expectedError.code)
        }
    }

    func test_execute_withNoDeviceID_throwsMissingDeviceIDWithoutRequestingAttempts() async {
        let (sut, doubles) = makeSUTAndDoubles()
        doubles.attemptsRepository.stubbedResult = .success(
            AttemptsResponse(remaining: 17, limit: 20, windowSeconds: 3_600)
        )

        do {
            _ = try await sut.execute()
            XCTFail("Expected an error")
        } catch let error as GetRemainingAttemptsUseCaseError {
            XCTAssertEqual(error, .missingDeviceID)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertTrue(doubles.attemptsRepository.receivedDeviceIDs.isEmpty)
    }
}

private extension GetRemainingAttemptsUseCaseTests {
    typealias SUT = GetRemainingAttemptsUseCase
    typealias Doubles = (deviceIDRepository: DeviceIDRepositoryStub, attemptsRepository: AttemptsRepositoryStub)

    func makeSUTAndDoubles() -> (sut: SUT, doubles: Doubles) {
        let deviceIDRepository = DeviceIDRepositoryStub()
        let attemptsRepository = AttemptsRepositoryStub()
        let sut = GetRemainingAttemptsUseCase(
            deviceIDRepository: deviceIDRepository,
            attemptsRepository: attemptsRepository
        )
        return (sut, (deviceIDRepository, attemptsRepository))
    }
}
