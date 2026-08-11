public protocol PersistentEntity {
    associatedtype ID: Hashable

    var id: ID { get }
}
