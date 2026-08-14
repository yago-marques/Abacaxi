import DomainInterfaces
import Foundation

final class GetDeviceIDUseCaseStub: GetDeviceIDUseCaseProtocol {
    var stubbedResult: Result<UUID?, Error> = .success(nil)

    func execute() throws -> UUID? {
        try stubbedResult.get()
    }
}
