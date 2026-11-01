//
//  BackButton.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

struct BackButton: View {
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {

            Button {

                dismiss()

            } label: {
                AppImage.Icon.close.image
            }
            .font(AppFont.Label.label.font)
            .foregroundStyle(AppColor.Text.secondary)
            .padding(AppToken.Padding.button)
            .frame(width: 44, height: 44)
            .background(AppColor.Button.Primary.background)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(AppColor.Button.Primary.border)
        }
    }
}

#Preview {
    BackButton()
}
