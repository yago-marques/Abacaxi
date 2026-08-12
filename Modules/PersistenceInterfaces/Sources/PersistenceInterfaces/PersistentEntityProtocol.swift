public protocol PersistentEntityProtocol {
    associatedtype ID: Hashable

    var id: ID { get }
}
