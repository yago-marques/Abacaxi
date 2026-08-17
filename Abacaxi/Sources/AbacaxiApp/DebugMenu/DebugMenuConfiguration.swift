import Foundation

struct DebugMenuConfiguration {
    private static let infoPlistKey = "AbacaxiDebugMenuEnabled"

    let isEnabled: Bool

    init(bundle: Bundle = .main) {
        let rawValue = bundle.object(forInfoDictionaryKey: Self.infoPlistKey) as? String
        let normalized = rawValue?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        isEnabled = normalized == "YES" || normalized == "TRUE"
    }
}
