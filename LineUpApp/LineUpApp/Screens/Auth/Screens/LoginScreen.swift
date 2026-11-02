//
//  LoginScreen.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

// Écran de connexion, ouvert depuis l'inscription (lien « J'ai déjà un compte »)
struct LoginScreen: View {

    @Environment(SessionStore.self) private var sessionStore

    var body: some View {
        LoginContent(sessionStore: sessionStore)
    }

}

struct LoginContent: View {

    @State private var viewModel: LoginViewModel

    @Environment(\.dismiss) private var dismiss

    init(sessionStore: SessionStore) {
        _viewModel = State(initialValue: LoginViewModel(sessionStore: sessionStore))
    }

    var body: some View {

        ScrollView {

            VStack(spacing: Styles.sectionGap) {

                // Champs
                VStack(alignment: .leading, spacing: Styles.fieldsGap) {

                    VStack(alignment: .leading, spacing: Styles.labelGap) {

                        Text(.loginEmail)
                            .lineupFont(Styles.labelFont)

                        FormInput(placeholder: .loginEmailPlaceholder, input: $viewModel.email, icon: Styles.emailIcon)
                            .textContentType(.username)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                    }

                    VStack(alignment: .leading, spacing: Styles.labelGap) {

                        Text(.passwordTitle)
                            .lineupFont(Styles.labelFont)

                        FormInput(
                            placeholder: .loginPasswordPlaceholder,
                            input: $viewModel.password,
                            icon: Styles.passwordIcon,
                            validation: viewModel.passwordValidation,
                            isSecure: true
                        )
                        .textContentType(.password)
                        .submitLabel(.go)
                        .onSubmit {
                            Task { await viewModel.submit() }
                        }

                    }

                }

                // Actions
                VStack(spacing: Styles.actionsGap) {

                    AppButton(title: "login.submit", type: .primary, status: viewModel.isLoading ? .loading : .idle, isFullWidth: true) {
                        Task { await viewModel.submit() }
                    }
                    .disabled(!viewModel.canSubmit)

                    // Retour à l'inscription, d'où on vient
                    HStack(spacing: Styles.linkGap) {

                        Text(.loginNoAccount)
                            .lineupFont(Styles.linkTextFont)

                        AppButton(title: "login.createAccount", type: .link) {
                            dismiss()
                        }

                    }

                }

            }
            .foregroundStyle(Styles.foreground)
            .padding(.horizontal, AppToken.Padding.screen)
            .padding(.top, AppToken.Padding.headerBottom)
            .padding(.bottom, AppToken.Padding.scrollViewBottom)

        }
        .scrollDismissesKeyboard(.interactively)
        .background(Styles.background)
        .lineupPageHeading(.secondary(title: .loginTitle, heading: .loginHeading, subtitle: .loginSubtitle)) {}

    }

}

fileprivate struct Styles {

    static let background = AppColor.Screen.background
    static let foreground = AppColor.Text.primary

    static let labelFont: AppFont = .Label.label
    static let linkTextFont: AppFont = .Body.body2

    static let labelGap = AppToken.Spacing.s8
    static let fieldsGap = AppToken.Spacing.s16
    static let sectionGap = AppToken.Spacing.s28
    static let actionsGap = AppToken.Spacing.s16
    static let linkGap = AppToken.Spacing.s4

    static let emailIcon = AppImage.InterfaceIcon.personSquareDuotone.image
    static let passwordIcon = AppImage.InterfaceIcon.lockDuotone.image

}

#Preview {

    let keychain = KeychainService()

    NavigationStack {
        LoginScreen()
    }
    .environment(SessionStore(service: AuthService(apiClient: APIClient(baseURL: APIConfig.baseURL, keychain: keychain), keychain: keychain)))

}

#Preview("Italiano") {

    let keychain = KeychainService()

    NavigationStack {
        LoginScreen()
    }
    .environment(SessionStore(service: AuthService(apiClient: APIClient(baseURL: APIConfig.baseURL, keychain: keychain), keychain: keychain)))
    .environment(\.locale, Locale(identifier: "it"))

}
