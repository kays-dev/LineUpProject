//
//  FilterHeader.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

struct FilterHeader: View {
    let title: String
    let icon: Image
    let font: Font

    var body: some View {

        HStack(spacing: AppToken.Spacing.s4) {
            icon.foregroundStyle(AppColor.ModalFilters.titleIcon)

            Text(title.uppercased())
        }
        .font(font)
        .foregroundStyle(AppColor.ModalFilters.textSecondary)

    }
}

#Preview("FilterHeader") {
    ZStack {
        Color.ink.ignoresSafeArea()

        FilterHeader(
            title: "Dates",
            icon: AppImage.Icon.calendar.image,
            font: AppFont.Label.label.font
        )
    }
}
