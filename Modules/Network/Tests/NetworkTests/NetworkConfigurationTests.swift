import XCTest
@testable import Network

final class NetworkConfigurationTests: XCTestCase {
    func test_fromInfoPlist_validBaseURL_returnsConfiguration() throws {
        let bundle = try makeBundle(infoPlist: ["APIBaseURL": "https://api.stage.example.com"])

        let configuration = try NetworkConfiguration.fromInfoPlist(bundle: bundle, isLoggingEnabled: true)

        XCTAssertEqual(configuration.baseURL, URL(string: "https://api.stage.example.com"))
        XCTAssertTrue(configuration.isLoggingEnabled)
    }

    func test_fromInfoPlist_missingKey_throwsMissingAPIBaseURL() throws {
        let bundle = try makeBundle(infoPlist: [:])

        XCTAssertThrowsError(try NetworkConfiguration.fromInfoPlist(bundle: bundle)) { error in
            XCTAssertEqual(error as? NetworkConfiguration.ConfigurationError, .missingAPIBaseURL)
        }
    }

    func test_fromInfoPlist_invalidURLString_throwsInvalidAPIBaseURL() throws {
        let invalidURLString = "https://[::1"
        let bundle = try makeBundle(infoPlist: ["APIBaseURL": invalidURLString])

        XCTAssertThrowsError(try NetworkConfiguration.fromInfoPlist(bundle: bundle)) { error in
            XCTAssertEqual(error as? NetworkConfiguration.ConfigurationError, .invalidAPIBaseURL(invalidURLString))
        }
    }

    private func makeBundle(infoPlist: [String: Any]) throws -> Bundle {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        addTeardownBlock { try? FileManager.default.removeItem(at: directory) }

        let plistURL = directory.appendingPathComponent("Info.plist")
        let data = try PropertyListSerialization.data(fromPropertyList: infoPlist, format: .xml, options: 0)
        try data.write(to: plistURL)

        return try XCTUnwrap(Bundle(url: directory))
    }
}

extension NetworkConfiguration.ConfigurationError: Equatable {
    public static func == (
        lhs: NetworkConfiguration.ConfigurationError,
        rhs: NetworkConfiguration.ConfigurationError
    ) -> Bool {
        switch (lhs, rhs) {
        case (.missingAPIBaseURL, .missingAPIBaseURL):
            return true
        case let (.invalidAPIBaseURL(lhsValue), .invalidAPIBaseURL(rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}
