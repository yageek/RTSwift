//
//  Keychain.swift
//  RTSwift
//
//  Created by Yannick Heinrich on 07.03.18.
//  Copyright © 2018 yageek. All rights reserved.
//

import Foundation
import Security

fileprivate let accountKey = "RTSwiftAPI"

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

final class KeychainWrapper {

    let encoder = PropertyListEncoder()
    let decoder = PropertyListDecoder()

    private let searchQuery: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                              kSecAttrServer as String: PublicMetadataAPI.absoluteString,
                                              kSecMatchLimit as String: kSecMatchLimitOne,
                                              kSecReturnAttributes as String: true,
                                              kSecReturnData as String: true]

    func getToken() throws -> AccessToken {
        var item: CFTypeRef?
        let status = SecItemCopyMatching(searchQuery as CFDictionary, &item)
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }

        guard let existingItem = item as? [String : Any],
            let passwordData = existingItem[kSecValueData as String] as? Data
            else {
                throw KeychainError.unexpectedPasswordData
        }
        return try decoder.decode(AccessToken.self, from: passwordData)
    }

    func saveToken(token: AccessToken) throws {
        // Check if a password already exists

        var shouldCreate = false
        do {
            let _ = try getToken()
        } catch let error as KeychainError {
            switch error {
            case .unexpectedPasswordData, .unhandledError(status: _):
                throw error
            case .noPassword:
                shouldCreate = true
            }
        }

        let password = try encoder.encode(token)
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
        kSecAttrAccount as String: accountKey,
        kSecAttrServer as String: PublicMetadataAPI.absoluteString,
        kSecValueData as String: password,
        kSecAttrProtocol as String: kSecAttrProtocolHTTP]

        if shouldCreate {
            let status = SecItemAdd(query as CFDictionary, nil)
            guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        } else {
            let status = SecItemUpdate(query as CFDictionary, query as CFDictionary)
            guard status != errSecItemNotFound else { throw KeychainError.noPassword }
            guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        }
    }

    func deleteToken() throws {
        let status = SecItemDelete(searchQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }
}
