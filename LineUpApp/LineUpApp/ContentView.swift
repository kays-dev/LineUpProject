//
//  ContentView.swift
//  LineUpApp
//
//  Created by Apprenant174 on 14/10/2026.
//

import SwiftUI

struct ContentView: View {
    
    @Bindable var filtersViewModel: WorkshopFiltersViewModel
    @State private var selection: LineUpTab = .affiche
    @State private var tabBarVisibility: TabBarVisibility = .visible
    @AppStorage("selectedAvatar") private var avatar: AppImage.Avatar = .colombina

    var body: some View {
        
        TabView(selection: $selection) {
            
            ForEach(LineUpTab.allCases) { tab in
                
                NavigationStack {
                    tab.rootView(viewModel: filtersViewModel)
                }
                .tag(tab)
                .toolbar(.hidden, for: .tabBar)
                
            }
            
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            
            if tabBarVisibility == .visible {
                TabBar(selection: $selection, avatar: avatar.image)
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
    let store = WorkshopStore(
        workshopService: WorkshopService(
            apiClient: APIClient(
                baseURL: URL(string: "http://localhost:8080")!,
                keychain: KeychainService()
            )
        )
    )

    let viewModel = WorkshopFiltersViewModel(workshopStore: store)

    return ContentView(filtersViewModel: viewModel)
}
