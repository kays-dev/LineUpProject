//
//  CardRibbon.swift
//  LineUpApp
//
//  Created by Apprenant174 on 31/10/2026.
//

import Foundation
import SwiftUI

struct CardRibbon: View {
    
    let categoryIcon: AppImage.Category
    
    let isMuted : Bool
    
    var body: some View {
        
        IconPattern(icon: isMuted ? categoryIcon.pastIcon : categoryIcon.icon)
            .frame(width: Styles.patternWidth, height: Styles.patternHeight)
            .clipShape(.rect(cornerRadius: Styles.cornerRadius))
            .background( isMuted ? Styles.fillMuted : Styles.fill)
            .overlay {
                
                RoundedRectangle(cornerRadius: Styles.cornerRadius)
                    .strokeBorder(isMuted ? Styles.borderMuted : Styles.border ,lineWidth: Styles.lineWidth)
                
            }
        
    }
    
}

fileprivate struct Styles {
    
    static let patternWidth : CGFloat = 600
    static let patternHeight : CGFloat = 50
    
    static let cornerRadius = AppToken.Radius.xsmall
    
    static let fill = Color.mintPrimary
    static let fillMuted = AppColor.Card.Muted.background
    
    static let lineWidth = AppToken.Border.thin
    static let border = AppColor.Card.Standard.border
    static let borderMuted = AppColor.Card.Muted.border
    
}

#Preview {
    CardRibbon(categoryIcon: .culture, isMuted: true)
}
