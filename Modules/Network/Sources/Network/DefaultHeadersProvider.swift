import Foundation
import NetworkInterfaces
#if canImport(UIKit)
import UIKit
#endif

struct DefaultHeadersProvider {
    private let bundle: Bundle
    private let deviceDescription: () -> String
    private let correlationID: () -> String

    init(
        bundle: Bundle = .main,
        deviceDescription: @escaping () -> String = Self.currentDeviceDescription,
        correlationID: @escaping () -> String = { "IOS-\(UUID().uuidString)" }
    ) {
        self.bundle = bundle
        self.deviceDescription = deviceDescription
        self.correlationID = correlationID
    }

    func headers() -> HTTPHeaders {
        HTTPHeaders([
            "X-App-Version": appVersion,
            "X-Device": deviceDescription(),
            "X-Correlation-Id": correlationID()
        ])
    }

    private var appVersion: String {
        let shortVersion = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
        let build = bundle.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        return "\(shortVersion) (\(build))"
    }

    static func currentDeviceDescription() -> String {
        #if canImport(UIKit)
        let device = UIDevice.current
        return "\(device.model) / iOS \(device.systemVersion)"
        #else
        let info = ProcessInfo.processInfo
        return "\(info.hostName) / \(info.operatingSystemVersionString)"
        #endif
    }
}
