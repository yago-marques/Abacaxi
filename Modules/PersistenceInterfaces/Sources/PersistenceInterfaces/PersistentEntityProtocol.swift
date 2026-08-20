public protocol PersistentEntityProtocol: Sendable {
    associatedtype ID: Hashable & Sendable

    var id: ID { get }
}
