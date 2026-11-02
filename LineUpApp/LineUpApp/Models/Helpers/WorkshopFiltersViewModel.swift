//
//  WorkshopFiltersViewModel.swift
//  LineUpApp
//
//  Created by Apprenant131 on 31/10/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class WorkshopFiltersViewModel {

    private let workshopStore: WorkshopStore

    init(workshopStore: WorkshopStore) {
        self.workshopStore = workshopStore
    }

    // Brouillon (lié à la feuille de filtres)
    var selectedPeriods: Set<String> = []
    var selectedCategories: Set<String> = []
    var selectedAvailability: Availability?

    // État appliqué
    private struct Snapshot {
        var periods: Set<String> = []
        var categories: Set<String> = []
        var availability: Availability?
    }
    private var applied = Snapshot()

    var errorMessage: String?
    
    var searchText = ""
    private var appliedName: String?

    private var trimmedName: String? {
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }

    // Catégories sélectionnées pour l'API
    var categories: String? {
        selectedCategories.isEmpty
            ? nil : selectedCategories.sorted().joined(separator: ",")
    }

    // Lecture depuis le store
    var workshops: [Workshop] { workshopStore.workshops }
    var availableDays: [String] { workshopStore.workshopDays }
    var availableCategories: [String] { workshopStore.allCategories }
    var isLoading: Bool { workshopStore.isLoading }

    
    // Actions
    func fetchWorkshopsDays() async throws {
        try await workshopStore.fetchWorkshopsDays()
    }
    
    func workshop(id: UUID) -> Workshop? {
        workshopStore.workshops.first { $0.id == id }
    }
    
    func refreshWorkshop(id: UUID) async {
        do {
            try await workshopStore.refreshWorkshop(id: id)
        } catch {
            errorMessage = "Impossible de mettre à jour l'atelier."
        }
    }

    func applyFilters() async throws {
        try await workshopStore.fetchWorkshops(
            name: trimmedName,
            periods: selectedPeriods.isEmpty ? nil : selectedPeriods.sorted(),
            category: categories,
            status: selectedAvailability?.apiValue
        )
        // mémorisé qu'après un succès
        appliedName = trimmedName
        applied = Snapshot(
            periods: selectedPeriods,
            categories: selectedCategories,
            availability: selectedAvailability
        )
    }
    
    func search() async {
        // anti-rebond : si le texte change pendant l'attente, la tâche est annulée
        try? await Task.sleep(for: .milliseconds(400))
        guard !Task.isCancelled, trimmedName != appliedName else { return }

        do {
            try await applyFilters()
        } catch is CancellationError {
            // remplacée par une requête plus récente : normal
        } catch let error as URLError where error.code == .cancelled {
            // idem
        } catch {
            errorMessage = "Recherche impossible."
        }
    }

    // « Annuler » : retour à l'état appliqué
    func cancelChanges() {
        selectedPeriods = applied.periods
        selectedCategories = applied.categories
        selectedAvailability = applied.availability
    }

    func resetFilters() {
        selectedPeriods.removeAll()
        selectedCategories.removeAll()
        selectedAvailability = nil
    }

    // Formatage
    func formatDate(_ date: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd/MM/yyyy"

        guard let convertedDate = inputFormatter.date(from: date) else {
            return date
        }
        return outputFormatter.string(from: convertedDate)
    }
}
