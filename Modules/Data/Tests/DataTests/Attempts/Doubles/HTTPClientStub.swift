import Foundation
import NetworkInterfaces

final class HTTPClientStub: HTTPClientProtocol {
    var stubbedData: Data?
    var stubbedError: Error?
    private(set) var receivedEndpoint: HTTPEndpointProtocol?

    func send<E: HTTPEndpointProtocol, T: Decodable>(_ endpoint: E) async throws -> T {
        receivedEndpoint = endpoint

        if let stubbedError {
            throw stubbedError
        }

        guard let stubbedData else {
            fatalError("A response must be configured for the requested type")
        }

        return try JSONDecoder().decode(T.self, from: stubbedData)
    }

    func send<E: HTTPEndpointProtocol, T: Decodable>(
        _ endpoint: E,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) -> CancellableProtocol {
        CancellableStub()
    }
}

private final class CancellableStub: CancellableProtocol {
    func cancel() {}
}
