//
//  LanguageScreen.swift
//  LineUpApp
//
//  Created by Apprenant174 on 02/11/2026.
//

import Foundation
import SwiftUI

struct LanguageScreen: View {

    @AppStorage("appLanguage") private var language: AppLanguage = .french

    var body: some View {
        ScrollView {
            VStack(spacing: AppToken.Spacing.s8) {
                SectionTitle(title: "language.section")
                ContentCard(theme: .light, size: .small) {
                    VStack(alignment: .leading, spacing: AppToken.Spacing.none) {
                        ForEach(AppLanguage.allCases, id: \.self) { option in
                            AppRadio(title: LocalizedStringKey(option.name), isSelected: language == option) {
                                language = option
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, AppToken.Padding.screen)
            .padding(.top, AppToken.Padding.headerBottom)
            .padding(.bottom, AppToken.Padding.scrollViewBottom)
        }
        .lineupPageHeading(.tertiary(heading: .languageTitle, subtitle: .languageSubtitle)) {}
        .background(AppColor.Screen.background)
    }
}

#Preview {
    LanguageScreen()
}
