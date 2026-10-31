//
//  FilterCapsule.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import SwiftUI

struct FilterCapsule: View {

    let title: String
    let isSelected: Bool

    var body: some View {

        // capsule
        HStack(spacing: AppToken.Spacing.s4) {
            Text(title)
        }
        .font(AppFont.Label.label.font)
        .foregroundStyle(AppColor.Text.primary)
        .padding(AppToken.Padding.button)
        .frame(maxWidth: .infinity)
        .background(
            isSelected
                ? AppColor.ModalFilters.Selected.background
                : AppColor.ModalFilters.Unselected.background
        )
        .clipShape(Capsule())
        // état de la capsule
        .overlay {
            Capsule()
                .stroke(
                    isSelected
                        ? AppColor.ModalFilters.Selected.border
                        : AppColor.ModalFilters.Unselected.border,
                    lineWidth: AppToken.Border.medium
                )
        }
    }
}

#Preview("FilterCapsule") {
    ZStack {
        Color.ink.ignoresSafeArea()

        VStack(spacing: 16) {
            FilterCapsule(
                title: "selectionné",
                isSelected: true
            )
            FilterCapsule(
                title: "non selectionné",
                isSelected: false
            )
        }
    }
}
