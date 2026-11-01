//
//  IconPattern.swift
//  LineUpApp
//
//  Created by Apprenant174 on 31/10/2026.
//

import Foundation
import SwiftUI

struct IconPattern: View {
    
    let icon: Image
    
    var body: some View {
        
        Canvas { context, size in
            
            guard let symbol = context.resolveSymbol(id: 0) else {
                
                return
                
            }
            
            let step = Styles.iconSize + Styles.spacing
            let rows = 2
            let columns = Int(size.width / step) + 2
            let topInset = (size.height - CGFloat(rows) * step) / 2
            
            for row in 0..<rows {
                
                let shift = row.isMultiple(of: 2) ? 0 : step / 2
                let y = topInset + CGFloat(row) * step + step / 2
                for column in 0..<columns {
                    
                    context.draw(symbol, at: CGPoint(x: CGFloat(column) * step + shift, y: y))
                    
                }
                
            }
            
        } symbols: {
            
            icon
                .resizable()
                .scaledToFit()
                .frame(width: Styles.iconSize, height: Styles.iconSize)
                .tag(0)
        }
        .clipped()
        
    }
    
}

fileprivate struct Styles {
    
    static var iconSize = AppToken.Scale.primitive24
    static var spacing = AppToken.Scale.primitive2
    
}

#Preview {
    IconPattern(icon: AppImage.Category.culture.icon)
}
