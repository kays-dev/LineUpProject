//
//  CancelledModalButton.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

struct CancelledModalButton: View {

    var text: String = ""
    var isSelected: Bool = false
    // closure pour effectuer différentes méthodes pour différentes utilisations
    var action: () -> Void

    var body: some View {

            Button {

                action()

            } label: {
                Text(text.uppercased())
            }
            .font(AppFont.Label.label.font)
            .foregroundStyle(
                isSelected
                ? AppColor.Button.Secondary.text
                : AppColor.Button.Disabled.text
            )
            .padding(AppToken.Padding.button)
            .frame(maxWidth: .infinity)
            .background(
                isSelected
                ? AppColor.Button.Secondary.background
                : AppColor.Button.Disabled.background
            )
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(
                        isSelected
                            ? AppColor.Button.Pressed.text
                            : AppColor.Button.Disabled.border,
                        lineWidth: AppToken.Border.medium
                    )
        }
    }
}

#Preview {
    CancelledModalButton(
        text: "Activer",
        isSelected: true,
        action: {}
    )
    
    CancelledModalButton(
        text: "Désactiver",
        isSelected: false,
        action: {}
    )
}
