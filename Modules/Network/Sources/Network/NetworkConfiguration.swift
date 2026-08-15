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
        // An unsubstituted build setting (missing xcconfig value) reaches the
        // Info.plist as the literal "$(API_BASE_URL)" and still parses as URL;
        // reject it and scheme-less values here so misconfiguration fails fast
        // at composition instead of surfacing as opaque transport errors.
        guard !rawValue.contains("$("),
              let url = URL(string: rawValue),
              url.scheme != nil else {
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
