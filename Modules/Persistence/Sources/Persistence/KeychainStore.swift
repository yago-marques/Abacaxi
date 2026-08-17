import Foundation
import PersistenceInterfaces
import Security

public enum KeychainError: Error {
    case missingBundleIdentifier
    case unhandledStatus(OSStatus)
}

public final class KeychainStore: SecureStoringProtocol {
    private let service: String

    public init() throws {
        guard let bundle = Bundle.main.bundleIdentifier else {
            throw KeychainError.missingBundleIdentifier
        }
        self.service = bundle
    }

    public func save(_ data: Data, forKey key: String) throws {
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let addQuery = baseQuery(forKey: key).merging(attributes) { _, new in new }
        let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
        if addStatus == errSecSuccess { return }
        guard addStatus == errSecDuplicateItem else {
            throw KeychainError.unhandledStatus(addStatus)
        }

        let updateStatus = SecItemUpdate(
            baseQuery(forKey: key) as CFDictionary,
            attributes as CFDictionary
        )
        guard updateStatus == errSecSuccess else {
            throw KeychainError.unhandledStatus(updateStatus)
        }
    }

    public func read(forKey key: String) throws -> Data? {
        var query = baseQuery(forKey: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess else {
            throw KeychainError.unhandledStatus(status)
        }
        return result as? Data
    }

    public func delete(forKey key: String) throws {
        let status = SecItemDelete(baseQuery(forKey: key) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledStatus(status)
        }
    }

    private func baseQuery(forKey key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
    }
}
