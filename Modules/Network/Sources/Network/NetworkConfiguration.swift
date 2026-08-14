import Foundation

public struct NetworkConfiguration {
    public let baseURL: URL
    public let isLoggingEnabled: Bool

    public init(baseURL: URL, isLoggingEnabled: Bool) {
        self.baseURL = baseURL
        self.isLoggingEnabled = isLoggingEnabled
    }

    public enum ConfigurationError: Error, Equatable {
        case missingAPIBaseURL
        case invalidAPIBaseURL(String)
    }

    public static func fromInfoPlist(
        bundle: Bundle,
        isLoggingEnabled: Bool = isDebugBuild
    ) throws -> NetworkConfiguration {
        guard let rawValue = bundle.object(forInfoDictionaryKey: "APIBaseURL") as? String,
              !rawValue.isEmpty else {
            throw ConfigurationError.missingAPIBaseURL
        }
        guard let url = URL(string: rawValue) else {
            throw ConfigurationError.invalidAPIBaseURL(rawValue)
        }
        return NetworkConfiguration(baseURL: url, isLoggingEnabled: isLoggingEnabled)
    }

    public static var isDebugBuild: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}
