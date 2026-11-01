//
//  WorkshopFiltersViewModel.swift
//  LineUpApp
//
//  Created by Apprenant131 on 31/10/2026.
//

import Foundation
import Observation

// garantit une isolation sur l'acteur principal
@MainActor
@Observable
final class WorkshopFiltersViewModel {

    // propriété permettant l'utilisation de WorkshopStore (stockage et mise à jour des ateliers)
    private let workshopStore: WorkshopStore

    init(workshopStore: WorkshopStore) {
        self.workshopStore = workshopStore
    }

    // stock les filtres selectionné
    var selectedPeriods: Set<String> = []
    var selectedCategories: Set<String> = []
    var selectedAvailability: Availability?

    // Catégories sélectionnées pour l'API
    var categories: String? {
        selectedCategories.isEmpty
            ? nil : selectedCategories.sorted().joined(separator: ",")
    }

    // au moin 1 filtre selectionné
    var hasActiveFilters: Bool {
        !selectedPeriods.isEmpty ||
        !selectedCategories.isEmpty ||
        selectedAvailability != nil

    }

    // Store
    var workshops: [Workshop] {
        workshopStore.workshops
    }

    var availableDays: [String] {
        workshopStore.workshopDays
    }
    
    // Récupération des dates
    func fetchWorkshopsDays() async throws {
        try await workshopStore.fetchWorkshopsDays()
    }
    
    // Sélection de la disponibilité
    func selectAvailability(_ availability: Availability?) {
            selectedAvailability = availability
    }

    // applique les filtres
    func applyFilters() async throws {
        try await workshopStore.fetchWorkshops(
            periods: selectedPeriods.isEmpty ? nil : Array(selectedPeriods),
            category: categories,
            status: selectedAvailability?.apiValue
        )
    }
    
    // filterButtonReset
    func resetFilters() {
        selectedPeriods.removeAll()
        selectedCategories.removeAll()
        selectedAvailability = nil
    }
    
    // Formattage de la date
    func formatDate(_ date: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd-MM-yyyy"

        guard let date = inputFormatter.date(from: date) else {
            return date
        }

        return outputFormatter.string(from: date)
    }

}
