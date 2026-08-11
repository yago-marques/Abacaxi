public protocol KeyValueStoring {
    func set<T>(_ value: T?, forKey key: String)
    func value<T>(forKey key: String) -> T?
    func removeValue(forKey key: String)
}
