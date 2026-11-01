//
//  SectionTitle.swift
//  LineUpApp
//
//  Created by Apprenant174 on 01/11/2026.
//

import Foundation
import SwiftUI

struct SectionTitle: View {

    let title: LocalizedStringKey

    var body: some View {
        Text(title)
            .lineupFont(AppFont.Body.section)
            .foregroundStyle(AppColor.Text.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    SectionTitle(title: "profile.stats")
        .padding(AppToken.Padding.screen)
}
