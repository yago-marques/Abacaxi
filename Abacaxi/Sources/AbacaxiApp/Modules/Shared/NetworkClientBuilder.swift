import Foundation
import Network
import NetworkInterfaces

enum NetworkClientBuilder {
    static func make() -> HTTPClientProtocol {
        networkClient
    }

    private static let networkClient: HTTPClientProtocol = {
        guard let configuration = try? NetworkConfiguration.fromInfoPlist(bundle: .main) else {
            fatalError("Failed to initialize NetworkConfiguration from Info.plist")
        }

        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 120
        sessionConfiguration.timeoutIntervalForResource = 150
        let session = URLSession(configuration: sessionConfiguration)
        return URLSessionHTTPClient(configuration: configuration, session: session)
    }()
}
