import Foundation

public protocol CreateDeviceIDUseCaseProtocol {
    @discardableResult
    func execute() throws -> UUID
}
