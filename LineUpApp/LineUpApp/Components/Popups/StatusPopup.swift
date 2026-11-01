//
//  StatusPopup.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import SwiftUI

struct StatusPopup: View {

    let type: AppColor.PopupType
    let title: String
    let message: String
    var buttonTitle: String
    var action: () -> Void

    var body: some View {

        VStack(spacing: AppToken.Spacing.s24) {

            VStack(spacing: AppToken.Spacing.s16) {

                type.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)

                VStack(spacing: AppToken.Spacing.s12) {
                    Text(title)
                        .font(AppFont.Title.title2.font)

                    Text(message)
                        .font(AppFont.Body.body.font)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .foregroundStyle(AppColor.Text.primary)
            }

            Button {
                action()
            } label: {
                Text(buttonTitle.uppercased())
                    .font(AppFont.Label.label.font)
                    .foregroundStyle(AppColor.Text.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppToken.Spacing.s12)
                    .background(type.buttons)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: AppToken.Radius.small
                        )
                    )
                    .overlay {
                        RoundedRectangle(
                            cornerRadius: AppToken.Radius.small
                        )
                        .stroke(
                            AppColor.Button.Primary.border,
                            lineWidth: AppToken.Border.medium
                        )
                    }
            }
        }
        .padding(.vertical, AppToken.Spacing.s24)
        .padding(.horizontal, AppToken.Spacing.s20)
        .frame(width: 300)
        .background(type.background)
        .clipShape(
            RoundedRectangle(cornerRadius: AppToken.Radius.big)
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppToken.Radius.big)
                .stroke(
                    AppColor.Button.Primary.border,
                    lineWidth: AppToken.Border.medium
                )
        }
    }
}

#Preview {
    StatusPopup(
        type: .validation,
        title: "Confirmation",
        message: "Votre réservation a bien été enregistrée.",
        buttonTitle: "Continuer",
        action: {}
    )

    StatusPopup(
        type: .danger,
        title: "Erreur",
        message: "Une erreur est survenue. Veuillez réessayer.",
        buttonTitle: "Fermer",
        action: {}
    )
}
