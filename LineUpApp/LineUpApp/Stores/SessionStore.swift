//
//  SessionStore.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class SessionStore {
    
    private(set) var user: User?
    private(set) var isRestoring = true
    
    var isLoggedIn: Bool {
        
        user != nil
        
    }
    
    private let service: AuthService
    
    init(service: AuthService) {
        self.service = service
    }
    
    // MARK: Restaurer la session au lancement de l'app
    func restoreSession() async {
        
        defer {
            isRestoring = false
        }
        
        do {
            
            user = try await service.profile()
            
        } catch APIError.badStatus(401) {
            
            // Token expiré ou invalide : on l'oublie
            try? service.logout()
            
        } catch {
            
            // Pas de token, ou pas de réseau : on reste déconnecté
            
        }
        
    }
    
    // MARK: Connexion
    func login(email: String, password: String) async throws {
        
        user = try await service.login(email: email, password: password)
        
    }
    
    // MARK: Inscription + connexion automatique (register() du service)
    func register(name: String, email: String, password: String) async throws {
        
        user = try await service.register(name: name, email: email, password: password)
        
    }
    
    // MARK: Déconnexion
    func logout() {
        
        try? service.logout()
        user = nil
        
    }
    
}
