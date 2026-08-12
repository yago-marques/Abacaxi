import Foundation

public protocol GetDeviceIDUseCaseProtocol {
    func execute() throws -> UUID?
}
