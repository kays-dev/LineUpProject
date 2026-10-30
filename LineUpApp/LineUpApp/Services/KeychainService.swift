//
//  KeychainService.swift
//  LineUpApp
//
//  Created by Apprenant174 on 30/10/2026.
//

import Foundation
import Security

enum KeychainError: Error {
    case notFound
    case unexpectedData
    case status(OSStatus)
}

// Stocke, lit et supprime le token. Ne le décode jamais.
final class KeychainService {
    private let service = "LineUpApp"
    private let account = "authToken"

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }

    // MARK: Enregistrer le token
    func save(token: String) throws {
        // On remplace l'ancien token s'il existe
        SecItemDelete(baseQuery as CFDictionary)

        var query = baseQuery
        query[kSecValueData as String] = Data(token.utf8)
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.status(status) }
    }

    // MARK: Lit le token pour savoir s'il existe
    func readToken() throws -> String {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status != errSecItemNotFound else { throw KeychainError.notFound }
        guard status == errSecSuccess else { throw KeychainError.status(status) }
        guard let data = item as? Data, let token = String(data: data, encoding: .utf8) else {
            throw KeychainError.unexpectedData
        }
        return token
    }

    // MARK: Supprime le token
    func deleteToken() throws {
        let status = SecItemDelete(baseQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.status(status)
        }
    }
}
