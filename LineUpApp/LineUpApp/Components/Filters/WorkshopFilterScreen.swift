//
//  WorkshopFilterScreen.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import SwiftUI

struct WorkshopFilterScreen: View {

    @Bindable var viewModel: WorkshopFiltersViewModel

    let dates: [String]
    let categories: [String]

    var body: some View {
        
        ZStack {
            Color.ink
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: AppToken.Spacing.s32) {
                    
                    // en tête (titre + retour)
                    HStack {
                        FilterHeader(
                            title: "Filtres",
                            icon: AppImage.Icon.filter.image,
                            font: AppFont.Title.heading.font
                        )
                        
                        // Button Back
                    }
                    
                    // Date
                    FilterSectionDateCategory(
                        title: "Dates",
                        icon: AppImage.Icon.calendar.image,
                        items: dates,
                        selection: $viewModel.selectedPeriods
                    )
                    
                    // Catégories
                    FilterSectionDateCategory(
                        title: "Catégories",
                        icon: AppImage.Icon.sparkles.image,
                        items: categories,
                        selection: $viewModel.selectedCategories
                    )
                    
                    // disponibilité
                    FilterSectionAvailability(
                        selection: $viewModel.selectedAvailability
                    )
                    
                    Spacer()
                    
                    // Bouton test
                    Button {
                        
                        print("Dates sélectionnées :", viewModel.selectedPeriods)
                        print("Catégories sélectionnées :", viewModel.selectedCategories)
                        print("Disponibilité sélectionnée :", viewModel.selectedAvailability as Any)
                        
                        Task {
                            do {
                                try await viewModel.applyFilters()
                                print("Filtrage terminé")
                                print("Nombre d'ateliers :", viewModel.workshops.count)
                            } catch {
                                print("Erreur lors du filtrage :", error)
                            }
                        }
                        
                    } label: {
                        Text("Appliquer")
                    }
                    
                }
                .padding(AppToken.Padding.screen)
            }
        }
    }
}


#Preview {
    let viewModel = WorkshopFiltersViewModel(
        workshopStore: WorkshopStore(
            workshopService: WorkshopService(
                apiClient: APIClient(
                    baseURL: URL(string: "http://localhost:8080")!,
                    keychain: KeychainService()
                )
            )
        )
    )

    ZStack {
        Color.ink
            .ignoresSafeArea()

        WorkshopFilterScreen(
            viewModel: viewModel,
            dates: [
                "2026-11-01",
                "2026-11-02",
                "2026-11-03"
            ],
            categories: [
                "Danse",
                "Musique",
                "Théâtre",
                "Cirque"
            ]
        )
    }
}
