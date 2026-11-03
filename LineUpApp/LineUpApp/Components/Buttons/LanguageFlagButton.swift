//
//  LanguageFlagButton.swift
//  LineUpApp
//
//  Created by Apprenant174 on 03/11/2026.
//

import Foundation
import SwiftUI

struct LanguageFlagButton: View {

    @AppStorage("appLanguage") private var language: AppLanguage = .french

    var body: some View {
        Button {
            language = language == .italian ? .french : .italian
        } label: {
            flag.image
                .resizable()
                .scaledToFit()
                .frame(width: AppToken.Scale.primitive28, height: AppToken.Scale.primitive28)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("settings.language"))
    }

    private var flag: AppImage.Flag {
        language == .italian ? .french : .italian
    }
}

#Preview {
    LanguageFlagButton()
}
