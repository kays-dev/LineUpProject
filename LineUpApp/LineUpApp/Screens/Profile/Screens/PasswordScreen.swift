//
//  PasswordScreen.swift
//  LineUpApp
//
//  Created by Apprenant174 on 02/11/2026.
//

import Foundation
import SwiftUI

struct PasswordScreen: View {

    @Environment(SessionStore.self) private var sessionStore
    @Environment(\.dismiss) private var dismiss
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var currentError: LocalizedStringResource?
    @State private var newError: LocalizedStringResource?
    @State private var confirmError: LocalizedStringResource?
    @State private var isSaving = false

    private let minimumLength = 8

    var body: some View {
        ScrollView {
            VStack(spacing: AppToken.Spacing.s28) {
                VStack(spacing: AppToken.Spacing.s16) {
                    field(label: "password.current", placeholder: .passwordCurrent, input: $currentPassword, error: currentError)
                    field(label: "password.new", placeholder: .passwordNew, input: $newPassword, error: newError)
                    field(label: "password.confirm", placeholder: .passwordConfirm, input: $confirmPassword, error: confirmError)
                }

                VStack(spacing: AppToken.Spacing.s12) {
                    AppButton(title: "common.save", type: .primary, isFullWidth: true) {
                        Task {
                            await save()
                        }
                    }
                    .disabled(isSaving)
                    AppButton(title: "common.cancel", type: .secondary, isFullWidth: true) {
                        dismiss()
                    }
                }
            }
            .padding(.horizontal, AppToken.Padding.screen)
        }
        .lineupPageHeading(.secondary(title: "", heading: .passwordTitle, subtitle: .passwordRule)) {}
        .tabBarVisibility(.hidden)
        .background(AppColor.Screen.background)
    }

    private func field(label: LocalizedStringKey, placeholder: LocalizedStringResource, input: Binding<String>, error: LocalizedStringResource?) -> some View {
        VStack(alignment: .leading, spacing: AppToken.Spacing.s8) {
            Text(label)
                .lineupFont(AppFont.Label.label)
                .foregroundStyle(AppColor.Text.primary)
            FormInput(placeholder: placeholder, input: input, icon: AppImage.InterfaceIcon.lockDuotone.image, validation: validation(for: error), isSecure: true)
        }
    }

    private func validation(for error: LocalizedStringResource?) -> FormInput.ValidationStage {
        if let error {
            return .invalid(message: error)
        }
        return .neutral
    }

    private func isValid(_ password: String) -> Bool {
        password.count >= minimumLength && password.contains { $0.isNumber }
    }

    private func save() async {
        currentError = nil
        newError = nil
        confirmError = nil

        if !isValid(newPassword) {
            newError = .passwordRule
        } else if newPassword == currentPassword {
            newError = .passwordErrorSame
        }
        if confirmPassword != newPassword {
            confirmError = .passwordErrorMismatch
        }
        guard newError == nil, confirmError == nil else {
            return
        }

        isSaving = true

        do {
            try await sessionStore.updatePassword(current: currentPassword, new: newPassword)
            isSaving = false
            dismiss()
        } catch APIError.badStatus(400) {
            isSaving = false
            currentError = .passwordErrorCurrent
        } catch {
            isSaving = false
            currentError = .passwordErrorGeneric
        }
    }
}

#Preview {
    let keychain = KeychainService()
    let apiClient = APIClient(baseURL: APIConfig.baseURL, keychain: keychain)

    PasswordScreen()
        .environment(SessionStore(service: AuthService(apiClient: apiClient, keychain: keychain)))
}
