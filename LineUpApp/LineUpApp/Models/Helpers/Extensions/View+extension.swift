//
//  View+extension.swift
//  LineUpApp
//
//  Created by Apprenant174 on 26/10/2026.
//

import Foundation
import SwiftUI

// MARK: Font styles à appliquer sur les texte dans les vues (Screens, Components, ...)
extension View {
    
    func lineupFont(_ style: AppFont) -> some View {
        
        font(style.font)
            .tracking(style.size * style.letterSpacing / 100)
            .lineSpacing(style.lineSpacing)
            .textCase(style.uppercase ? .uppercase : nil)
        
    }
    
}

// MARK: Enlever la TabBar dans les écrans enfants
extension View {
    
    // À mettre sur les écrans de niveau 2 et 3 (`.tabBarVisibility(.hidden)`)
    func tabBarVisibility(_ visibility: TabBarVisibility) -> some View {
        preference(key: TabBarVisibilityPreferenceKey.self, value: visibility)
    }
    
}

// MARK: Ajouter le Heading dans les écrans
extension View {
    
    // À mettre après les ScrollView dans les écrans (`.lineupPageHeading(.secondary(title: .settingsTitle)) {}`). Ne pas oublier le `.toolbar(.hidden, for: .navigationBar)` dans les écrans concernés.
    func lineupPageHeading<Trailing: View>(_ mode: PageHeading<Trailing>.Mode, @ViewBuilder trailing: () -> Trailing) -> some View {

        self
            .safeAreaBar(edge: .top) { PageHeading(mode: mode, trailing: trailing) }
            .toolbar(.hidden, for: .navigationBar)
    }
    
}
