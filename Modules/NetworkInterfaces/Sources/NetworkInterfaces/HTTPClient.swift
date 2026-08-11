public protocol HTTPClient {
    func send<E: HTTPEndpoint, T: Decodable>(_ endpoint: E) async throws -> T

    @discardableResult
    func send<E: HTTPEndpoint, T: Decodable>(
        _ endpoint: E,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) -> Cancellable
}
