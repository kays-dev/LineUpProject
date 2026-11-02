//
//  PasswordScreen.swift
//  LineUpApp
//
//  Created by Apprenant174 on 02/11/2026.
//

import Foundation
import SwiftUI

struct PasswordScreen: View {

    @Environment(\.dismiss) private var dismiss
    @State private var currentPassword = "••••••••••"
    @State private var newPassword = "••••••••••••"
    @State private var confirmPassword = "••••••••••••"

    var body: some View {
        ScrollView {
            VStack(spacing: AppToken.Spacing.s28) {
                VStack(spacing: AppToken.Spacing.s16) {
                    field(label: "password.current", placeholder: .passwordCurrent, input: $currentPassword)
                    field(label: "password.new", placeholder: .passwordNew, input: $newPassword)
                    field(label: "password.confirm", placeholder: .passwordConfirm, input: $confirmPassword)
                }

                VStack(spacing: AppToken.Spacing.s12) {
                    AppButton(title: "common.save", type: .primary, isFullWidth: true) {
                        dismiss()
                    }
                    AppButton(title: "common.cancel", type: .secondary, isFullWidth: true) {
                        dismiss()
                    }
                }
            }
            .padding(.horizontal, AppToken.Padding.screen)
            .padding(.top, AppToken.Padding.headerBottom)
            .padding(.bottom, AppToken.Padding.scrollViewBottom)
        }
        .lineupPageHeading(.tertiary(heading: .passwordTitle, subtitle: .passwordRule)) {}
        .background(AppColor.Screen.background)
    }

    private func field(label: LocalizedStringKey, placeholder: LocalizedStringResource, input: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: AppToken.Spacing.s8) {
            Text(label)
                .lineupFont(AppFont.Label.label)
                .foregroundStyle(AppColor.Text.primary)
            FormInput(placeholder: placeholder, input: input, icon: AppImage.InterfaceIcon.lockDuotone.image)
        }
    }
}

#Preview {
    PasswordScreen()
}
