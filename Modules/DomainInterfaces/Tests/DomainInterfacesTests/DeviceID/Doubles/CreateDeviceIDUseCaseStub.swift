import Foundation
@testable import DomainInterfaces

final class CreateDeviceIDUseCaseStub: CreateDeviceIDUseCaseProtocol {
    var stubbedID = UUID()

    func execute() throws -> UUID {
        stubbedID
    }
}
