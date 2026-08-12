import DataInterfaces
import DomainInterfaces

public enum GetRemainingAttemptsUseCaseFactory {
    public static func make(
        deviceIDRepository: DeviceIDRepositoryProtocol,
        attemptsRepository: AttemptsRepositoryProtocol
    ) -> GetRemainingAttemptsUseCaseProtocol {
        GetRemainingAttemptsUseCase(
            deviceIDRepository: deviceIDRepository,
            attemptsRepository: attemptsRepository
        )
    }
}

public enum GetRemainingAttemptsUseCaseError: Error, Equatable {
    case missingDeviceID
}

public final class GetRemainingAttemptsUseCase: GetRemainingAttemptsUseCaseProtocol {
    private let deviceIDRepository: DeviceIDRepositoryProtocol
    private let attemptsRepository: AttemptsRepositoryProtocol

    public init(
        deviceIDRepository: DeviceIDRepositoryProtocol,
        attemptsRepository: AttemptsRepositoryProtocol
    ) {
        self.deviceIDRepository = deviceIDRepository
        self.attemptsRepository = attemptsRepository
    }

    public func execute() async throws -> RemainingAttempts {
        guard let deviceID = try deviceIDRepository.load() else {
            throw GetRemainingAttemptsUseCaseError.missingDeviceID
        }

        let response = try await attemptsRepository.fetchAttempts(deviceID: deviceID)
        return RemainingAttempts(
            remaining: response.remaining,
            limit: response.limit,
            windowSeconds: response.windowSeconds
        )
    }
}
