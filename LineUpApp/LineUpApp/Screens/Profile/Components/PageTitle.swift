//
//  PageTitle.swift
//  LineUpApp
//
//  Created by Apprenant174 on 01/11/2026.
//

import Foundation
import SwiftUI

struct PageTitle: View {

    let title: LocalizedStringKey

    var body: some View {
        HStack(spacing: AppToken.Spacing.none) {
            Text(title)
                .foregroundStyle(AppColor.Logo.text)
            Text(verbatim: ".")
                .foregroundStyle(AppColor.Logo.dot)
        }
        .lineupFont(AppFont.Title.heading)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: AppToken.Spacing.s16) {
        PageTitle(title: "profile.title")
        PageTitle(title: "settings.title")
    }
    .padding(AppToken.Padding.screen)
}
