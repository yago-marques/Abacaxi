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

    func test_fromInfoPlist_unsubstitutedBuildSetting_throwsInvalidAPIBaseURL() throws {
        let placeholder = "$(API_BASE_URL)"
        let bundle = try makeBundle(infoPlist: ["APIBaseURL": placeholder])

        XCTAssertThrowsError(try NetworkConfiguration.fromInfoPlist(bundle: bundle)) { error in
            XCTAssertEqual(error as? NetworkConfiguration.ConfigurationError, .invalidAPIBaseURL(placeholder))
        }
    }

    func test_fromInfoPlist_schemelessURL_throwsInvalidAPIBaseURL() throws {
        let schemeless = "api.stage.example.com"
        let bundle = try makeBundle(infoPlist: ["APIBaseURL": schemeless])

        XCTAssertThrowsError(try NetworkConfiguration.fromInfoPlist(bundle: bundle)) { error in
            XCTAssertEqual(error as? NetworkConfiguration.ConfigurationError, .invalidAPIBaseURL(schemeless))
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
