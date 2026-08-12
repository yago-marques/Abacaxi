import Foundation

enum APIKeyBuilder {
    static func make(bundle: Bundle = .main) -> String {
        guard let apiKey = bundle.object(forInfoDictionaryKey: "APIKey") as? String,
              !apiKey.isEmpty,
              !apiKey.contains("$(") else {
            fatalError("APIKey must be configured in Configs/Secrets.xcconfig")
        }

        return apiKey
    }
}
