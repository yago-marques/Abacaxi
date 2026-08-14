import Foundation

/// Reads the debug menu flag injected by the build configuration.
///
/// `ENABLE_DEBUG_MENU` flows from `Configs/Environments/*.xcconfig` into the
/// `AbacaxiDebugMenuEnabled` Info.plist entry (`YES` on Stage, `NO` on Production).
struct DebugMenuConfiguration {
    private static let infoPlistKey = "AbacaxiDebugMenuEnabled"

    let isEnabled: Bool

    init(bundle: Bundle = .main) {
        let rawValue = bundle.object(forInfoDictionaryKey: Self.infoPlistKey) as? String
        let normalized = rawValue?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        isEnabled = normalized == "YES" || normalized == "TRUE"
    }
}
