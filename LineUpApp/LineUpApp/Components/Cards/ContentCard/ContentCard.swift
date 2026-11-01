//
//  ContentCard.swift
//  LineUpApp
//
//  Created by Apprenant174 on 01/11/2026.
//

import SwiftUI

struct ContentCard<Content: View>: View {
    
    let theme : Theme
    let size : Size
    @ViewBuilder let content : Content
    
    private var styles : Styles {
        Styles(for: theme, size: size)
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            content
            
        }
        .padding(styles.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(styles.foreground)
        .background {
            RoundedRectangle(cornerRadius: Styles.cornerRadius)
                .fill(styles.fill)
                .strokeBorder(Styles.border, lineWidth: Styles.lineWidth)
        }
        
        
    }
    
}

enum Theme {
    
    case dark
    case light
    
}

enum Size {
    
    case small
    case big
}

fileprivate struct Styles {
    
    // Styles fixes
    static let cornerRadius = AppToken.Radius.xsmall
    static let border = Color.ink
    static let lineWidth = AppToken.Border.thin
    
    // Styles conditionnels
    let fill : Color
    let foreground : Color
    let padding : EdgeInsets
    
    init(for theme : Theme, size : Size) {
        
        switch theme {
        case .dark:
            fill = .ink
            foreground = AppColor.Text.secondary
            
        case .light:
            fill = AppColor.Card.Standard.background
            foreground = AppColor.Text.primary
            
        }
        
        switch size {
            
        case .small:
            padding = AppToken.Padding.smallCard
            
        case .big:
            padding = AppToken.Padding.field
            
        }
        
    }
    
}
