//
//  PrivacyScreen.swift
//  LineUpApp
//
//  Created by Apprenant174 on 02/11/2026.
//

import Foundation
import SwiftUI

struct PrivacyScreen: View {

    private let contactEmail = "dpo@exemple.fr"

    var body: some View {
        ScrollView {
            VStack(spacing: AppToken.Spacing.s28) {
                VStack(spacing: AppToken.Spacing.s16) {
                    LegalSection(title: "privacy.collected.title", text: "privacy.collected.text")
                    LegalSection(title: "privacy.use.title", text: "privacy.use.text")
                    LegalSection(title: "privacy.retention.title", text: "privacy.retention.text")
                    LegalSection(title: "privacy.rights.title", text: "privacy.rights.text")
                    LegalSection(title: "privacy.contact.title", text: "privacy.contact.text \(contactEmail)")
                }

                AppButton(title: "privacy.download", type: .secondary, isFullWidth: true) {}
            }
            .padding(.horizontal, AppToken.Padding.screen)
        }
        .lineupPageHeading(.secondary(title: "", heading: .privacyTitle, subtitle: .privacySubtitle)) {}
        .tabBarVisibility(.hidden)
        .background(AppColor.Screen.background)
    }
}

#Preview {
    PrivacyScreen()
}
