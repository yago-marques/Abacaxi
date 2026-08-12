import Foundation
import NetworkInterfaces

/// `URLSession`-backed `HTTPClientProtocol`. Both call styles share the same request-building
/// (`makeURLRequest`) and response-mapping (`mapResult`/`decode`) logic; they differ only
/// in which `URLSession` API they call to actually perform the transfer.
public final class URLSessionHTTPClient: HTTPClientProtocol {
    private let session: URLSession
    private let configuration: NetworkConfiguration
    private let defaultHeadersProvider: DefaultHeadersProvider
    private let logger: ConsoleRequestLogger
    private let decoder: JSONDecoder

    public init(
        configuration: NetworkConfiguration,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.configuration = configuration
        self.session = session
        self.decoder = decoder
        self.defaultHeadersProvider = DefaultHeadersProvider()
        self.logger = ConsoleRequestLogger(isEnabled: configuration.isLoggingEnabled)
    }

    public func send<E: HTTPEndpointProtocol, T: Decodable>(_ endpoint: E) async throws -> T {
        let urlRequest = try makeURLRequest(from: endpoint)
        logger.logRequest(urlRequest)

        let data: Data
        let response: URLResponse
        do {
            // `URLSession.data(for:)` cancels its underlying task and propagates Task
            // cancellation on its own — no manual continuation/cancellable plumbing needed.
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            logger.logResponse(nil, data: nil, error: error)
            return try Self.mapResult(data: nil, response: nil, error: error, decoder: decoder).get()
        }

        let httpResponse = response as? HTTPURLResponse
        logger.logResponse(httpResponse, data: data, error: nil)
        return try Self.mapResult(data: data, response: httpResponse, error: nil, decoder: decoder).get()
    }

    @discardableResult
    public func send<E: HTTPEndpointProtocol, T: Decodable>(
        _ endpoint: E,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) -> CancellableProtocol {
        let urlRequest: URLRequest
        do {
            urlRequest = try makeURLRequest(from: endpoint)
        } catch let networkError as NetworkError {
            completion(.failure(networkError))
            return NoopCancellable()
        } catch {
            completion(.failure(.invalidURL))
            return NoopCancellable()
        }

        logger.logRequest(urlRequest)

        let task = session.dataTask(with: urlRequest) { [logger, decoder] data, response, error in
            let httpResponse = response as? HTTPURLResponse
            logger.logResponse(httpResponse, data: data, error: error)
            completion(Self.mapResult(data: data, response: httpResponse, error: error, decoder: decoder))
        }
        task.resume()
        return URLSessionTaskCancellable(task: task)
    }

    private func makeURLRequest(from endpoint: some HTTPEndpointProtocol) throws -> URLRequest {
        let trimmedPath = endpoint.path.hasPrefix("/") ? String(endpoint.path.dropFirst()) : endpoint.path
        let base = endpoint.baseURL ?? configuration.baseURL
        guard var components = URLComponents(
            url: base.appendingPathComponent(trimmedPath),
            resolvingAgainstBaseURL: false
        ) else {
            throw NetworkError.invalidURL
        }
        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.httpBody = endpoint.body

        let headers = HeaderResolution.resolve(
            requestHeaders: endpoint.headers,
            defaults: defaultHeadersProvider.headers(),
            hasBody: endpoint.body != nil
        )
        for (key, value) in headers.dictionary {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        return urlRequest
    }

    private static func mapResult<T: Decodable>(
        data: Data?,
        response: HTTPURLResponse?,
        error: Error?,
        decoder: JSONDecoder
    ) -> Result<T, NetworkError> {
        if let error {
            if (error as NSError).code == NSURLErrorCancelled {
                return .failure(.cancelled)
            }
            return .failure(.transport(error))
        }
        guard let response else {
            return .failure(.invalidResponse)
        }
        guard (200..<300).contains(response.statusCode) else {
            return .failure(.statusCode(response.statusCode, data: data))
        }
        do {
            return .success(try decode(T.self, from: data ?? Data(), decoder: decoder))
        } catch {
            return .failure(.decoding(error))
        }
    }

    private static func decode<T: Decodable>(_ type: T.Type, from data: Data, decoder: JSONDecoder) throws -> T {
        if type == EmptyResponse.self {
            return EmptyResponse() as! T // swiftlint:disable:this force_cast
        }
        return try decoder.decode(T.self, from: data)
    }
}
