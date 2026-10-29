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
