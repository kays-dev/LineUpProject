//
//  InfoRow.swift
//  LineUpApp
//
//  Created by Apprenant174 on 02/11/2026.
//

import SwiftUI

// Ligne « libellé + valeur » des ContentCard (détail de réservation, historique)
struct InfoRow: View {
    
    let label: LocalizedStringResource   // traduit
    let value: String                    // donnée de l'API, affichée telle quelle
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: Styles.gap) {
            
            Text(label)
                .lineupFont(Styles.labelFont)
            
            Text(value)
                .lineupFont(Styles.valueFont)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
}

fileprivate struct Styles {
    
    static let labelFont: AppFont = .Label.label
    static let valueFont: AppFont = .Body.body
    static let gap = AppToken.Spacing.s8
    
}

#Preview {
    
    ContentCard(theme: .dark, size: .big) {
        
        InfoRow(label: .bookingFullName, value: "Giulia Rossi")
        InfoRow(label: .bookingWorkshop, value: "La Locandiera")
        
    }
    .padding()
    
}
