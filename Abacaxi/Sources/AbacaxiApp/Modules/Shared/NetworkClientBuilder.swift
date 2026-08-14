import Foundation
import Network
import NetworkInterfaces

enum NetworkClientBuilder {
    private enum Constants {
        // Recipe generation is LLM-backed and can legitimately take up to two
        // minutes; these ceilings must stay above the backend's worst case.
        static let requestTimeout: TimeInterval = 120
        static let resourceTimeout: TimeInterval = 150
    }

    static func make() -> HTTPClientProtocol {
        networkClient
    }

    private static let networkClient: HTTPClientProtocol = {
        guard let configuration = try? NetworkConfiguration.fromInfoPlist(bundle: .main) else {
            fatalError("Failed to initialize NetworkConfiguration from Info.plist")
        }

        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = Constants.requestTimeout
        sessionConfiguration.timeoutIntervalForResource = Constants.resourceTimeout
        let session = URLSession(configuration: sessionConfiguration)
        return URLSessionHTTPClient(configuration: configuration, session: session)
    }()
}
