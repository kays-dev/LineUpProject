//
//  TermsScreen.swift
//  LineUpApp
//
//  Created by Apprenant174 on 02/11/2026.
//

import Foundation
import SwiftUI

struct TermsScreen: View {

    var body: some View {
        ScrollView {
            VStack(spacing: AppToken.Spacing.s16) {
                LegalSection(title: "terms.1.title", text: "terms.1.text")
                LegalSection(title: "terms.2.title", text: "terms.2.text")
                LegalSection(title: "terms.3.title", text: "terms.3.text")
                LegalSection(title: "terms.4.title", text: "terms.4.text")
                LegalSection(title: "terms.5.title", text: "terms.5.text")
            }
            .padding(.horizontal, AppToken.Padding.screen)
            .padding(.top, AppToken.Padding.headerBottom)
            .padding(.bottom, AppToken.Padding.scrollViewBottom)
        }
        .lineupPageHeading(.secondary(title: "", heading: .termsTitle, subtitle: .termsUpdated)) {}
        .tabBarVisibility(.hidden)
        .background(AppColor.Screen.background)
    }
}

#Preview {
    TermsScreen()
}
