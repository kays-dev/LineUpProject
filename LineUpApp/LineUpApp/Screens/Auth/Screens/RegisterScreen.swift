//
//  RegisterScreen.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

// Écran d'inscription : premier écran quand on n'est pas connecté
struct RegisterScreen: View {

    @Environment(SessionStore.self) private var sessionStore

    var body: some View {
        RegisterContent(sessionStore: sessionStore)
    }

}

struct RegisterContent: View {

    @State private var viewModel: RegisterViewModel

    @State private var showLogin = false

    init(sessionStore: SessionStore) {
        _viewModel = State(initialValue: RegisterViewModel(sessionStore: sessionStore))
        _showLogin = State(initialValue: sessionStore.hasLoggedOut)
    }

    var body: some View {

        ScrollView {

            VStack(alignment: .leading, spacing: Styles.sectionGap) {

                Text(.registerSubtitle)
                    .lineupFont(Styles.subtitleFont)

                // Champs
                VStack(alignment: .leading, spacing: Styles.fieldsGap) {

                    VStack(alignment: .leading, spacing: Styles.labelGap) {

                        Text(.registerName)
                            .lineupFont(Styles.labelFont)

                        FormInput(placeholder: .registerNamePlaceholder, input: $viewModel.name, icon: Styles.nameIcon)
                            .textContentType(.name)
                            .textInputAutocapitalization(.words)

                    }

                    VStack(alignment: .leading, spacing: Styles.labelGap) {

                        Text(.loginEmail)
                            .lineupFont(Styles.labelFont)

                        FormInput(placeholder: .loginEmailPlaceholder, input: $viewModel.email, validation: viewModel.emailValidation)
                            .textContentType(.emailAddress)
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
                            validation: viewModel.passwordValidation, isSecure: true
                        )
                        .textContentType(.newPassword)

                    }

                    VStack(alignment: .leading, spacing: Styles.labelGap) {

                        Text(.registerPasswordConfirm)
                            .lineupFont(Styles.labelFont)

                        FormInput(
                            placeholder: .registerPasswordConfirmPlaceholder,
                            input: $viewModel.passwordConfirm,
                            icon: Styles.passwordIcon,
                            validation: viewModel.passwordConfirmValidation,
                            isSecure: true
                        )
                        .textContentType(.newPassword)
                        .submitLabel(.go)
                        .onSubmit {
                            Task { await viewModel.submit() }
                        }

                    }

                }

                // Actions
                VStack(spacing: Styles.actionsGap) {

                    AppButton(title: "register.submit", type: .primary, status: viewModel.isLoading ? .loading : .idle, isFullWidth: true) {
                        Task { await viewModel.submit() }
                    }
                    .disabled(!viewModel.canSubmit)

                    // Erreur réseau ou serveur (le 409 s'affiche sous le champ e-mail)
                    if let errorMessage = viewModel.errorMessage {

                        Text(errorMessage)
                            .lineupFont(Styles.errorFont)
                            .foregroundStyle(Styles.errorColor)
                            .multilineTextAlignment(.center)

                    }

                    HStack(spacing: Styles.linkGap) {

                        Text(.registerHasAccount)
                            .lineupFont(Styles.linkTextFont)

                        AppButton(title: "register.login", type: .link) {
                            showLogin = true
                        }

                    }

                }
                .frame(maxWidth: .infinity)

            }
            .foregroundStyle(Styles.foreground)
            .padding(.horizontal, AppToken.Padding.screen)
            .padding(.top, AppToken.Padding.headerBottom)
            .padding(.bottom, AppToken.Padding.scrollViewBottom)

        }
        .scrollDismissesKeyboard(.interactively)
        .background(Styles.background)
        .lineupPageHeading(.primary(heading: .registerTitle)) {}
        .navigationDestination(isPresented: $showLogin) {

            LoginScreen()

        }

    }

}

fileprivate struct Styles {

    static let background = AppColor.Screen.background
    static let foreground = AppColor.Text.primary

    static let subtitleFont: AppFont = .Body.body
    static let labelFont: AppFont = .Label.label
    static let linkTextFont: AppFont = .Body.body2
    static let errorFont: AppFont = .Body.caption
    static let errorColor = Color.dangerDark

    static let labelGap = AppToken.Spacing.s8
    static let fieldsGap = AppToken.Spacing.s16
    static let sectionGap = AppToken.Spacing.s28
    static let actionsGap = AppToken.Spacing.s16
    static let linkGap = AppToken.Spacing.s4

    static let nameIcon = AppImage.InterfaceIcon.personSquareDuotone.image
    static let passwordIcon = AppImage.InterfaceIcon.lockDuotone.image

}

#Preview {

    let keychain = KeychainService()

    NavigationStack {
        RegisterScreen()
    }
    .environment(SessionStore(service: AuthService(apiClient: APIClient(baseURL: APIConfig.baseURL, keychain: keychain), keychain: keychain)))

}

#Preview("Italiano") {

    let keychain = KeychainService()

    NavigationStack {
        RegisterScreen()
    }
    .environment(SessionStore(service: AuthService(apiClient: APIClient(baseURL: APIConfig.baseURL, keychain: keychain), keychain: keychain)))
    .environment(\.locale, Locale(identifier: "it"))

}
