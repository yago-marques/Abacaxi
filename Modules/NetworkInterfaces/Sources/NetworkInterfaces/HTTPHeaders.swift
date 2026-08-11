public struct HTTPHeaders: ExpressibleByDictionaryLiteral, Equatable {
    private var storage: [String: String]

    public init(_ storage: [String: String] = [:]) {
        self.storage = storage
    }

    public init(dictionaryLiteral elements: (String, String)...) {
        self.storage = Dictionary(uniqueKeysWithValues: elements)
    }

    public subscript(name: String) -> String? {
        get { storage[name] }
        set { storage[name] = newValue }
    }

    public var isEmpty: Bool { storage.isEmpty }

    public var dictionary: [String: String] { storage }

    public func merging(_ other: HTTPHeaders) -> HTTPHeaders {
        HTTPHeaders(storage.merging(other.storage) { _, new in new })
    }
}
