import DomainInterfaces
import Foundation

final class CreateDeviceIDUseCaseStub: CreateDeviceIDUseCaseProtocol {
    private(set) var executeCallCount = 0
    var stubbedID = UUID()

    func execute() throws -> UUID {
        executeCallCount += 1
        return stubbedID
    }
}
