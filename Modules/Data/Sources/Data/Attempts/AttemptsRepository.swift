import DataInterfaces
import Foundation
import NetworkInterfaces

public enum AttemptsRepositoryFactory {
    public static func make(
        httpClient: HTTPClientProtocol,
        apiKey: String
    ) -> AttemptsRepositoryProtocol {
        AttemptsRepository(httpClient: httpClient, apiKey: apiKey)
    }
}

public final class AttemptsRepository: AttemptsRepositoryProtocol {
    private let httpClient: HTTPClientProtocol
    private let apiKey: String

    public init(httpClient: HTTPClientProtocol, apiKey: String) {
        self.httpClient = httpClient
        self.apiKey = apiKey
    }

    public func fetchAttempts(deviceID: UUID) async throws -> AttemptsResponse {
        let response: Response = try await httpClient.send(Endpoint(deviceID: deviceID, apiKey: apiKey))
        return AttemptsResponse(
            remaining: response.remaining,
            limit: response.limit,
            windowSeconds: response.windowSeconds
        )
    }
}

private extension AttemptsRepository {
    struct Endpoint: HTTPEndpointProtocol {
        let deviceID: UUID
        let apiKey: String

        let path = "/v1/attempts"

        var headers: HTTPHeaders {
            [
                "X-Device-ID": deviceID.uuidString,
                "X-API-Key": apiKey
            ]
        }
    }

    struct Response: Decodable {
        let remaining: Int
        let limit: Int
        let windowSeconds: Int

        enum CodingKeys: String, CodingKey {
            case remaining
            case limit
            case windowSeconds = "window_seconds"
        }
    }
}
