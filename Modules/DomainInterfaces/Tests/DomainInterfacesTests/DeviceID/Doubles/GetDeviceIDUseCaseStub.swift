import Foundation
@testable import DomainInterfaces

final class GetDeviceIDUseCaseStub: GetDeviceIDUseCaseProtocol {
    var stubbedID: UUID?

    func execute() throws -> UUID? {
        stubbedID
    }
}
