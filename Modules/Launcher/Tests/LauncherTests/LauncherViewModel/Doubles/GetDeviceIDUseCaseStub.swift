import DomainInterfaces
import Foundation

final class GetDeviceIDUseCaseStub: GetDeviceIDUseCaseProtocol {
    var stubbedID: UUID?

    func execute() throws -> UUID? {
        stubbedID
    }
}
