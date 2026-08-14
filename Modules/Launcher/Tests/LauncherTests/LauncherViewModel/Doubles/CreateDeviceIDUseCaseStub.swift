import DomainInterfaces
import Foundation

final class CreateDeviceIDUseCaseStub: CreateDeviceIDUseCaseProtocol {
    private(set) var executeCallCount = 0
    var stubbedResult: Result<UUID, Error> = .success(UUID())

    func execute() throws -> UUID {
        executeCallCount += 1
        return try stubbedResult.get()
    }
}
