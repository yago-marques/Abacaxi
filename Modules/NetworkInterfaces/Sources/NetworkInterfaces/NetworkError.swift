import Foundation

public enum NetworkError: Error {
    case invalidURL
    case transport(Error)
    case invalidResponse
    case statusCode(Int, data: Data?)
    case decoding(Error)
    case cancelled
}
