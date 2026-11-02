//
//  RegisterViewModel.swift
//  LineUpApp
//
//  Created by Apprenant174 on 02/11/2026.
//

import Foundation

// Logique de l'écran d'inscription : saisie, règles de validation, appel au SessionStore, messages d'erreur
@Observable
@MainActor
final class RegisterViewModel {

    var name = ""

    // Un nouvel e-mail efface l'erreur « déjà utilisé »
    var email = "" {
        didSet { emailTaken = false }
    }

    var password = ""
    var passwordConfirm = ""

    private(set) var isLoading = false
    private(set) var emailTaken = false
    private(set) var errorMessage: LocalizedStringResource?

    private let sessionStore: SessionStore

    // Règle affichée dans la clé password.rule : au moins 8 caractères, dont un chiffre
    private let passwordMinLength = 8

    init(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }

    // MARK: Règles
    private var isEmailValid: Bool {
        email.contains("@") && email.contains(".")
    }

    private var isPasswordValid: Bool {
        password.count >= passwordMinLength && password.contains(where: \.isNumber)
    }

    private var passwordsMatch: Bool {
        !passwordConfirm.isEmpty && password == passwordConfirm
    }

    var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && isEmailValid
            && isPasswordValid
            && passwordsMatch
            && !isLoading
    }

    // MARK: États des champs (rien tant que le champ est vide)
    var emailValidation: FormInput.ValidationStage {
        if emailTaken {
            return .invalid(message: .registerErrorEmailTaken)
        }
        return isEmailValid ? .valid : .neutral
    }

    var passwordValidation: FormInput.ValidationStage {
        if password.isEmpty {
            return .neutral
        }
        return isPasswordValid ? .valid : .invalid(message: .passwordRule)
    }

    var passwordConfirmValidation: FormInput.ValidationStage {
        if passwordConfirm.isEmpty {
            return .neutral
        }
        return passwordsMatch ? .valid : .invalid(message: .registerErrorMismatch)
    }

    // MARK: Inscription + connexion automatique
    func submit() async {

        guard canSubmit else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            
            try await sessionStore.register(
                name: name.trimmingCharacters(in: .whitespaces),
                email: email.trimmingCharacters(in: .whitespaces),
                password: password
            )
            
        } catch APIError.badStatus(409) {
            
            emailTaken = true
            
        } catch {
            
            errorMessage = .registerErrorGeneric
            
        }
        
    }
}
