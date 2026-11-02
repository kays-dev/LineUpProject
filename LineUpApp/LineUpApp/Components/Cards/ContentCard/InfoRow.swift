//
//  InfoRow.swift
//  LineUpApp
//
//  Created by Apprenant174 on 02/11/2026.
//

import SwiftUI

struct InfoRow: View {
    
    let label: LocalizedStringResource
    let value: String
    
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
    static let gap = AppToken.Spacing.s4
    
}

#Preview {
    
    ContentCard(theme: .dark, size: .big) {
        
        InfoRow(label: .bookingFullName, value: "Giulia Rossi")
            .padding(.bottom, AppToken.Spacing.s16)
        
        InfoRow(label: .bookingWorkshop, value: "La Locandiera")
        
    }
    .padding()
    
}
