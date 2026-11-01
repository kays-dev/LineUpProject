//
//  TabBarItem.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import SwiftUI

struct TabBarItem: View {
    
    let tab: LineUpTab
    let avatar: Image
    let action: () -> Void

    var body: some View {
        
        Button(action: action) {
            
            VStack(spacing: 4) {
                
                if tab == .aparte {
                    
                    avatar
                        .resizable()
                        .scaledToFill()
                        .frame(width: 46, height: 46)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(Color.mintPrimary, lineWidth: 2))
                    
                } else {
                    
                    tab.inactiveIcon
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Text(tab.label)
                        .lineupFont(AppFont.Navigation.tabBarLabel)
                    
                }
                
            }
            .foregroundStyle(Color.tealLight)
            .frame(width: 102, height: 62)
            .contentShape(Rectangle())
            
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.label)
        
    }
    
}

#Preview {
    HStack(spacing: 0) {
        ForEach(LineUpTab.allCases, id: \.self) { tab in
            TabBarItem(tab: tab, avatar: Image("avatar-colombina")) {}
        }
    }
    .background(Capsule().fill(Color.ink))
}
