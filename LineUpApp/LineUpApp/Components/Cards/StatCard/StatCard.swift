//
//  Numbercard.swift
//  LineUpApp
//
//  Created by Apprenant174 on 01/11/2026.
//

import SwiftUI

struct StatCard: View {
    
    let valueInString : String
    
    let label : String
    let icon : Image
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HStack(alignment: .bottom, spacing: Styles.gap) {
                
                Text(valueInString)
                    .lineupFont(Styles.font)
                
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: Styles.iconSize, height: Styles.iconSize)
                    .foregroundStyle(Styles.iconColor)
                    .padding(Styles.iconPadding)
                    .background {
                        
                        RoundedRectangle(cornerRadius: Styles.iconCornerRadius)
                            .fill(Styles.iconBackgroundFill)
                        
                    }
                
            }
            
            Text(label)
                .lineupFont(Styles.labelFont)
            
        }
        .padding(Styles.padding)
        .frame(maxWidth: Styles.maxWidth)
        .foregroundStyle(Styles.foreground)
        .background {
            RoundedRectangle(cornerRadius: Styles.cornerRadius)
                .fill(Styles.fill)
                .strokeBorder(Styles.border, lineWidth: Styles.lineWidth)
        }
        
    }
    
}

fileprivate struct Styles {
    
    static let labelFont : AppFont = .Body.body2
    static let font : AppFont = .Title.title2
    
    static let fill : Color = AppColor.Card.Standard.background
    static let gap : CGFloat = AppToken.Spacing.s16
    static let cornerRadius = AppToken.Radius.small
    static let padding = AppToken.Padding.caps * 2
    static let maxWidth : CGFloat = 168 + gap
    
    static let foreground : Color = AppColor.Text.primary
    
    static let border = AppColor.Card.Standard.border
    static let lineWidth = AppToken.Border.thin
    
    static let iconCornerRadius = AppToken.Radius.xsmall
    static let iconBackgroundFill = Color.ink
    static let iconColor = Color.greenPrimary
    static let iconSize : CGFloat = 32
    static let iconPadding = AppToken.Padding.icon * 2
}

#Preview {
    StatCard(valueInString: "Théâtre", label: "intitulé", icon: AppImage.Icon.sparkles.image)
}
