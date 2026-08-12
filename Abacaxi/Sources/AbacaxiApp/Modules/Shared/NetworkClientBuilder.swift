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
        return URLSessionHTTPClient(configuration: configuration)
    }()
}
