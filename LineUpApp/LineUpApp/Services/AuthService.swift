//
//  AuthService.swift
//  LineUpApp
//
//  Created by Apprenant174 on 26/10/2026.
//

import Foundation

final class AuthService {
    
    private let apiClient: APIClient
    private let keychain: KeychainService
    
    init(apiClient: APIClient, keychain: KeychainService) {
        self.apiClient = apiClient
        self.keychain = keychain
    }
    
    // MARK: Récupérer les informations de l'utilisateur
    func profile() async throws -> User {
        
        let response : UserResponse = try await apiClient.request(path: "appios/users/me")
        
        return response.toModel()
        
    }
    
    // MARK: Authentifier l'utilisateur et récupérer ses informations
    func login(email: String, password: String) async throws -> User {
        
        let data = try await apiClient.perform(path: "auth/login", method: .post, body: LoginRequest(email: email, password: password))
        
        guard let token = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !token.isEmpty else {
            
            throw APIError.invalidToken
            
        }
        
        try keychain.save(token: token)
        return try await profile()
        
    }
    
    // MARK: Créer l'utilisateur, l'authentifier et récupérer ses informations
    func register(name: String, email: String, password: String) async throws -> User {
        
        let _ : UserResponse = try await apiClient.request(path: "appios/users", method: .post, body: RegisterRequest(name: name, email: email, password: password))
        
        return try await login(email: email, password: password)
        
    }
    
    // MARK: Modifier le mot de passe de l'utilisateur
    func updatePassword(current: String, new: String) async throws {
        
        _ = try await apiClient.perform(path: "appios/users/me/password", method: .patch, body: UpdatePasswordRequest(currentPassword: current, newPassword: new))
        
    }
    
    // MARK: Déconnecter l'utilisateur
    func logout() throws {
        
        try keychain.deleteToken()
        
    }
    
//    // MARK: Supprimer le compte de l'utilisateur
//    func deleteAccount() async throws {
//        
//        _ = try await apiClient.perform(path: "appios/users/me", method: .delete)
//        
//        try logout()
//        
//    }
    
}
