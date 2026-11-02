//
//  LegalSection.swift
//  LineUpApp
//
//  Created by Apprenant174 on 02/11/2026.
//

import Foundation
import SwiftUI

struct LegalSection: View {

    let title: LocalizedStringKey
    let text: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: AppToken.Spacing.s8) {
            SectionTitle(title: title)
            Text(text)
                .lineupFont(AppFont.Body.body2)
                .foregroundStyle(AppColor.Text.tertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    LegalSection(title: "terms.1.title", text: "terms.1.text")
        .padding(AppToken.Padding.screen)
}
