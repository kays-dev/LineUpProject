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
    @State private var categoryStore: CategoryStore
    @State private var filtersViewModel: WorkshopFiltersViewModel
    @State private var reservationStore: ReservationStore

    init() {
        let keychain = KeychainService()
        let apiClient = APIClient(
            baseURL: APIConfig.baseURL,
            keychain: keychain
        )

        let workshopStore = WorkshopStore(
            workshopService: WorkshopService(apiClient: apiClient)
        )

        _sessionStore = State(initialValue: SessionStore(
            service: AuthService(
                apiClient: apiClient,
                keychain: keychain
            )
        ))

        _workshopStore = State(initialValue: workshopStore)

        _categoryStore = State(initialValue: CategoryStore(
            service: CategoryService(apiClient: apiClient)
        ))
        _filtersViewModel = State(
            initialValue: WorkshopFiltersViewModel(
                workshopStore: workshopStore
            )
        )
        _reservationStore = State(initialValue: ReservationStore(
            service: ReservationService(apiClient: apiClient)
        ))
    }

    var body: some Scene {
        WindowGroup {
            
            WorkshopFilterScreen(
                viewModel: filtersViewModel,
                dates: workshopStore.workshopDays,
                categories: categoryStore.categories.map { $0.name }
            )
            .environment(sessionStore)
            .environment(workshopStore)
            .environment(categoryStore)
            .task {
                do {
                    try await filtersViewModel.fetchWorkshopsDays()
                    try await categoryStore.fetchAll()

                    print("Dates récupérées :", workshopStore.workshopDays)
                    print("Catégories récupérées :", categoryStore.categories.map { $0.name })

                } catch {
                    print("Erreur lors du chargement des filtres :", error)
                }
            }
            
//            ContentView()
//                .environment(sessionStore)
//                .environment(workshopStore)
//                .environment(categoryStore)
//                .environment(reservationStore)

        }
    }
}



//import SwiftUI
//
//@main
//struct LineUpAppApp: App {
//    
//    @State private var sessionStore: SessionStore
//    @State private var workshopStore: WorkshopStore
//    @State private var categoryStore: CategoryStore
//    
//    init() {
//        let keychain = KeychainService()
//        let apiClient = APIClient(baseURL: APIConfig.baseURL, keychain: keychain)
//        
//        _sessionStore = State(initialValue: SessionStore(
//            service: AuthService(apiClient: apiClient, keychain: keychain)
//        ))
//        _workshopStore = State(initialValue: WorkshopStore(
//            workshopService: WorkshopService(apiClient: apiClient)
//        ))
//        _categoryStore = State(initialValue: CategoryStore(
//            service: CategoryService(apiClient: apiClient)
//        ))
//    }
//    
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .environment(sessionStore)
//                .environment(workshopStore)
//                .environment(categoryStore)
//        }
//    }
//}
