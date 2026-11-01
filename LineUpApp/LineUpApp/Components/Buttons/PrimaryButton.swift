//
//  PrimaryButton.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

struct PrimaryButton: View {

    var text: String = ""
    var border: Color = AppColor.Button.Primary.border
    var isSelected: Bool = false
    // closure pour effectuer différentes méthodes pour différentes utilisations
    var action: () -> Void
    // utilisation :
    // PrimaryButton(
    // text: "Activer",
    // isSelected: true
    // ) {
    // activer()
    // }

    var body: some View {

            Button {

                action()

            } label: {
                Text(text.uppercased())
            }
            .font(AppFont.Label.label.font)
            .foregroundStyle(
                isSelected
                    ? AppColor.Text.secondary
                    : AppColor.Text.tertiary
            )
            .padding(AppToken.Padding.button)
            .frame(maxWidth: .infinity)
            .background(
                isSelected
                ? AppColor.Button.Primary.background
                : AppColor.Button.Disabled.background
            )
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(
                        isSelected
                            ? border
                            : AppColor.Button.Disabled.border,
                        lineWidth: AppToken.Border.medium
                    )
        }
    }
}

#Preview {
    PrimaryButton(
        text: "Activer",
        isSelected: true,
        action: {}
    )
    
    PrimaryButton(
        text: "Désactiver",
        isSelected: false,
        action: {}
    )
}
