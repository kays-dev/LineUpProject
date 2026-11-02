//
//  LoginViewModel.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

// Logique de l'écran de connexion : saisie, validation, appel au SessionStore, message d'erreur
@Observable
@MainActor
final class LoginViewModel {

    // Toute nouvelle saisie efface l'erreur précédente
    var email = "" {
        didSet { errorMessage = nil }
    }

    var password = "" {
        didSet { errorMessage = nil }
    }

    private(set) var errorMessage: LocalizedStringResource?
    private(set) var isLoading = false

    private let sessionStore: SessionStore

    init(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }

    var canSubmit: Bool {
        email.contains("@") && !password.isEmpty && !isLoading
    }

    // L'erreur s'affiche sous le champ mot de passe (bordure Danger + message)
    var passwordValidation: FormInput.ValidationStage {
        
        if let errorMessage {
            return .invalid(message: errorMessage)
        }
        return .neutral
        
    }

    // Pas de navigation après le succès : SessionStore.user est rempli, et l'écran racine bascule tout seul sur les onglets
    func submit() async {

        guard canSubmit else { return }

        isLoading = true
        
        defer { isLoading = false }

        do {
            
            try await sessionStore.login(email: email.trimmingCharacters(in: .whitespaces), password: password)
            
        } catch APIError.badStatus(401) {
            
            errorMessage = .loginErrorCredentials
            
        } catch {
            
            errorMessage = .loginErrorGeneric
            
        }
    }
}
