//
//  LoadingScreen.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

// Affiché pendant restoreSession() au lancement
struct LoadingScreen: View {

    var body: some View {

        ProgressView()
            .controlSize(.large)
            .tint(Styles.tint)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Styles.background)
            .accessibilityLabel(Text("common.loading"))

    }

}

fileprivate struct Styles {

    static let background = AppColor.Screen.background
    static let tint = Color.redPrimary

}

#Preview {
    LoadingScreen()
}
