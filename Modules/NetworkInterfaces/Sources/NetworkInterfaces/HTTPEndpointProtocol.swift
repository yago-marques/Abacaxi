import Foundation

public protocol HTTPEndpointProtocol {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders { get }
    var queryItems: [URLQueryItem] { get }
    var body: Data? { get }
    var baseURL: URL? { get }
}

public extension HTTPEndpointProtocol {
    var method: HTTPMethod { .get }
    var headers: HTTPHeaders { [:] }
    var queryItems: [URLQueryItem] { [] }
    var body: Data? { nil }
    var baseURL: URL? { nil }
}
