//
//  Badge.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

struct BadgeView: View {
    let title: String
    let availability: Availability
    let icon: AppImage.Category
    
    var body: some View {
        HStack(spacing: AppToken.Spacing.s4) {
            Text(title.uppercased())
                .font(AppFont.Label.label.font)
                .foregroundStyle(
                    availability == .available
                    ? AppColor.Capsule.Available.text
                    : AppColor.Capsule.Full.text
                )

            Image(icon.imageName)
                .resizable()
                .frame(width: 16, height: 16)
        }
        .padding(.vertical, AppToken.Scale.primitive4)
        .padding(.horizontal, AppToken.Scale.primitive12)
        .background(
            availability == .available
            ? AppColor.Capsule.Available.background
            : AppColor.Capsule.Full.background
        )
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(
                    availability == .available
                    ? AppColor.Capsule.Available.border
                    : AppColor.Capsule.Full.border,
                    lineWidth: AppToken.Border.thin
                )
        }
    }
}

#Preview {
    BadgeView(
        title: "valide",
        availability: .available,
        icon: .culture
    )
    BadgeView(
        title: "invalide",
        availability: .full,
        icon: .movie
    )
}
