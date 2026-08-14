import Foundation

public enum NetworkError: Error {
    case invalidURL
    case transport(any Error)
    case invalidResponse
    case statusCode(Int, data: Data?)
    case decoding(any Error)
    case cancelled
}
