//
//  SettingsScreen.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

struct SettingsScreen: View {

    @Environment(SessionStore.self) private var sessionStore
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedAvatar") private var avatar: AppImage.Avatar = .colombina
    @AppStorage("notifications.reminder") private var reminderEnabled = true
    @AppStorage("notifications.spot") private var spotEnabled = true
    @AppStorage("notifications.news") private var newsEnabled = false
    @AppStorage("appLanguage") private var language: AppLanguage = .french
    @State private var showsDeletePopup = false
    @State private var showsLanguage = false
    @State private var showsAvatar = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppToken.Spacing.s28) {
                identity
                account
                notifications
                preferences
                about
                session
            }
            .padding(.horizontal, AppToken.Padding.screen)
            .padding(.bottom, AppToken.Padding.scrollViewBottom)
        }
        .safeAreaBar(edge: .top) {
            header
        }
        .background(AppColor.Screen.background)
        .toolbar(.hidden, for: .navigationBar)
        .tabBarVisibility(.hidden)
        .overlay {
            if showsDeletePopup {
                deletePopup
            }
        }
        .sheet(isPresented: $showsLanguage) {
            LanguageScreen()
        }
        .sheet(isPresented: $showsAvatar) {
            AvatarScreen()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppToken.Spacing.s16) {
            AppButton(type: .back) {
                dismiss()
            }
            PageTitle(title: "settings.title")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppToken.Padding.screen)
        .padding(.bottom, AppToken.Padding.headerBottom)
    }

    private var identity: some View {
        HStack(spacing: AppToken.Spacing.s16) {
            avatar.image
                .resizable()
                .scaledToFill()
                .frame(width: AppToken.Avatar.settings, height: AppToken.Avatar.settings)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .strokeBorder(AppColor.AvatarPicker.photoBorder, lineWidth: AppToken.Border.medium)
                }
                .accessibilityHidden(true)

            if let user = sessionStore.user {
                VStack(alignment: .leading, spacing: AppToken.Spacing.s4) {
                    Text(user.name)
                        .lineupFont(AppFont.Title.title2)
                        .foregroundStyle(AppColor.Text.primary)
                    Text(user.email)
                        .lineupFont(AppFont.Body.body2)
                        .foregroundStyle(AppColor.Text.tertiary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var account: some View {
        VStack(spacing: AppToken.Spacing.s8) {
            SectionTitle(title: "settings.account")
            ContentCard(theme: .light, size: .small) {
                VStack(spacing: AppToken.Spacing.none) {
                    Button {
                        showsAvatar = true
                    } label: {
                        SettingsRow(
                            icon: AppImage.InterfaceIcon.maskDuotone.image,
                            title: "settings.avatar",
                            subtitle: "settings.avatar.subtitle",
                            accessory: .value(avatar.name)
                        )
                    }
                    .buttonStyle(.plain)
                    SettingsRow(
                        icon: AppImage.InterfaceIcon.lockDuotone.image,
                        title: "settings.password",
                        subtitle: "settings.password.subtitle",
                        accessory: .chevron,
                        showsSeparator: false
                    )
                }
            }
        }
    }

    private var notifications: some View {
        VStack(spacing: AppToken.Spacing.s8) {
            SectionTitle(title: "settings.notifications")
            ContentCard(theme: .light, size: .small) {
                VStack(spacing: AppToken.Spacing.none) {
                    SettingsRow(
                        icon: AppImage.InterfaceIcon.bellDuotone.image,
                        title: "settings.notif.reminder",
                        subtitle: "settings.notif.reminder.subtitle",
                        accessory: .toggle($reminderEnabled),
                        showsSeparator: false
                    )
                    SettingsRow(
                        icon: AppImage.InterfaceIcon.ticketDuotone.image,
                        title: "settings.notif.spot",
                        subtitle: "settings.notif.spot.subtitle",
                        accessory: .toggle($spotEnabled),
                        showsSeparator: false
                    )
                    SettingsRow(
                        icon: AppImage.InterfaceIcon.sparkleDuotone.image,
                        title: "settings.notif.news",
                        accessory: .toggle($newsEnabled),
                        showsSeparator: false
                    )
                }
            }
        }
    }

    private var preferences: some View {
        VStack(spacing: AppToken.Spacing.s8) {
            SectionTitle(title: "settings.preferences")
            ContentCard(theme: .light, size: .small) {
                Button {
                    showsLanguage = true
                } label: {
                    SettingsRow(
                        icon: AppImage.InterfaceIcon.mapDuotone.image,
                        title: "settings.language",
                        accessory: .value(language.name),
                        showsSeparator: false
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var about: some View {
        VStack(spacing: AppToken.Spacing.s8) {
            SectionTitle(title: "settings.about")
            ContentCard(theme: .light, size: .small) {
                VStack(spacing: AppToken.Spacing.none) {
                    SettingsRow(
                        icon: AppImage.InterfaceIcon.infoDuotone.image,
                        title: "settings.terms",
                        accessory: .chevron,
                        showsSeparator: false
                    )
                    SettingsRow(
                        icon: AppImage.InterfaceIcon.lockDuotone.image,
                        title: "settings.privacy",
                        accessory: .chevron,
                        showsSeparator: false
                    )
                }
            }
        }
    }

    private var session: some View {
        VStack(spacing: AppToken.Spacing.s16) {
            AppButton(title: "settings.logout", type: .secondary, isFullWidth: true) {
                sessionStore.logout()
            }
            AppButton(title: "settings.deleteAccount", type: .text, tone: .danger) {
                showsDeletePopup = true
            }
            Text("settings.version \(appVersion)")
                .lineupFont(AppFont.Body.caption)
                .foregroundStyle(AppColor.Text.tertiary)
        }
    }

    private var deletePopup: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture {
                    showsDeletePopup = false
                }

            StatusPopup(
                type: .danger,
                title: String(localized: "settings.deleteAccount.title"),
                message: String(localized: "settings.deleteAccount.message"),
                buttonTitle: String(localized: "settings.deleteAccount")
            ) {
                showsDeletePopup = false
            }
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
}

#Preview {
    let keychain = KeychainService()
    let apiClient = APIClient(baseURL: APIConfig.baseURL, keychain: keychain)

    NavigationStack {
        SettingsScreen()
    }
    .environment(SessionStore(service: AuthService(apiClient: apiClient, keychain: keychain)))
}
