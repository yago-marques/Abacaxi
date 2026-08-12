public final class UseCaseContainer {
    private var factories: [ObjectIdentifier: () -> Any] = [:]

    public init() {}

    public func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        factories[ObjectIdentifier(type)] = factory
    }

    public func registerSingleton<T>(_ type: T.Type, instance: T) {
        factories[ObjectIdentifier(type)] = { instance }
    }

    public func resolve<T>(_ type: T.Type) -> T {
        guard let factory = factories[ObjectIdentifier(type)] else {
            fatalError("\(type) not registered in UseCaseContainer")
        }
        guard let instance = factory() as? T else {
            fatalError("Registered factory for \(type) returned an invalid type")
        }
        return instance
    }
}
