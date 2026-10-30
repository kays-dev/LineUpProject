//
//  LineUpAppApp.swift
//  LineUpApp
//
//  Created by Apprenant174 on 14/10/2026.
//

import SwiftUI

@main
struct LineUpAppApp: App {
    
    @State private var sessionStore: SessionStore
    @State private var workshopStore: WorkshopStore
    
    init() {
        let keychain = KeychainService()
        let apiClient = APIClient(baseURL: APIConfig.baseURL, keychain: keychain)
        
        _sessionStore = State(initialValue: SessionStore(
            service: AuthService(apiClient: apiClient, keychain: keychain)
        ))
        _workshopStore = State(initialValue: WorkshopStore(
            workshopService: WorkshopService(apiClient: apiClient)
        ))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(sessionStore)
                .environment(workshopStore)
        }
    }
}
