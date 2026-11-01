//
//  ContentView.swift
//  LineUpApp
//
//  Created by Apprenant174 on 14/10/2026.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selection: LineUpTab = .affiche
    @State private var tabBarVisibility: TabBarVisibility = .visible
    
    var body: some View {
        
        TabView(selection: $selection) {
            
            ForEach(LineUpTab.allCases) { tab in
                
                NavigationStack {
                    tab.rootView
                }
                
                .tag(tab)
                .toolbar(.hidden, for: .tabBar)
                
            }
            
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            
            if tabBarVisibility == .visible {
                TabBar(selection: $selection, avatar: Image(.avatarColombina))
                    .transition(.move(edge: .bottom))
            }
            
        }
        .onPreferenceChange(TabBarVisibilityPreferenceKey.self) { visibility in
            
            withAnimation(.easeOut(duration: 0.25)) {
                tabBarVisibility = visibility
            }
            
        }
        
    }
        
}

#Preview {
    ContentView()
}
