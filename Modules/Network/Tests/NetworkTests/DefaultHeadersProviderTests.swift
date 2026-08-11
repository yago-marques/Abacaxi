import XCTest
@testable import Network

final class DefaultHeadersProviderTests: XCTestCase {
    func test_headers_includesAppVersionDeviceAndCorrelationId() throws {
        let provider = DefaultHeadersProvider(
            bundle: try makeBundle(shortVersion: "2.1", build: "42"),
            deviceDescription: { "iPhone15,2 / iOS 17.5" },
            correlationID: { "IOS-fixed-id" }
        )

        let headers = provider.headers()

        XCTAssertEqual(headers["X-App-Version"], "2.1 (42)")
        XCTAssertEqual(headers["X-Device"], "iPhone15,2 / iOS 17.5")
        XCTAssertEqual(headers["X-Correlation-Id"], "IOS-fixed-id")
    }

    func test_correlationID_hasIOSPrefixAndIsUniquePerCall() throws {
        let provider = DefaultHeadersProvider(bundle: try makeBundle(shortVersion: "1.0", build: "1"))

        let first = provider.headers()["X-Correlation-Id"]
        let second = provider.headers()["X-Correlation-Id"]

        XCTAssertNotEqual(first, second)
        XCTAssertTrue(first?.hasPrefix("IOS-") == true)
        XCTAssertTrue(second?.hasPrefix("IOS-") == true)
    }

    private func makeBundle(shortVersion: String, build: String) throws -> Bundle {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        addTeardownBlock { try? FileManager.default.removeItem(at: directory) }

        let plist: [String: Any] = [
            "CFBundleShortVersionString": shortVersion,
            "CFBundleVersion": build
        ]
        let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try data.write(to: directory.appendingPathComponent("Info.plist"))

        return try XCTUnwrap(Bundle(url: directory))
    }
}
