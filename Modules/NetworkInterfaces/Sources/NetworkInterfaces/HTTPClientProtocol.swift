public protocol HTTPClientProtocol {
    func send<E: HTTPEndpointProtocol, T: Decodable>(_ endpoint: E) async throws -> T

    @discardableResult
    func send<E: HTTPEndpointProtocol, T: Decodable>(
        _ endpoint: E,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) -> any CancellableProtocol
}
