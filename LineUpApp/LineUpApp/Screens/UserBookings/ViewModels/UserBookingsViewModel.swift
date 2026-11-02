//
//  UserBookingsViewModel.swift
//  LineUpApp
//
//  Created by Apprenant174 on 02/11/2026.
//

import Foundation

// Logique de l'Agenda : recherche, filtres, sections, chargement et annulation
@Observable
@MainActor
final class UserBookingsViewModel {

    var query = ""
    var showsCancelError = false

    // Sélection de la modale de filtres (propre à l'Agenda : ne touche pas aux filtres de l'Affiche)
    let filters: WorkshopFiltersViewModel

    private let reservationStore: ReservationStore
    private let workshopStore: WorkshopStore
    private let categoryStore: CategoryStore

    init(reservationStore: ReservationStore, workshopStore: WorkshopStore, categoryStore: CategoryStore) {
        
        self.reservationStore = reservationStore
        self.workshopStore = workshopStore
        self.categoryStore = categoryStore
        self.filters = WorkshopFiltersViewModel(workshopStore: workshopStore)
        
    }

    // MARK: Sections
    var ongoing: [Reservation] {
        visibleReservations.filter(\.isOngoing)
    }

    var upcoming: [Reservation] {
        visibleReservations.filter(\.isUpcoming)
    }

    var waitlist: [Reservation] {
        visibleReservations.filter(\.isWaiting)
    }

    // Réservations annulées avec workshop toujours à venir ou en cours
    var cancelled: [Reservation] {
        visibleReservations.filter { $0.status == .cancelled && !$0.isPast }
    }
    
    // MARK: Contenu de la modale de filtres
    var filterDays: [String] {
        workshopStore.workshopDays
    }

    var filterCategories: [String] {
        categoryStore.categories.map(\.name)
    }

    // MARK: Chargement
    func load() async {
        
        do {
            try await reservationStore.fetchAll()

            // Récupère les jours de workshop
            if workshopStore.workshopDays.isEmpty {
                try await workshopStore.fetchWorkshopsDays()
            }
            
            // Récupère toutes les catégories
            if categoryStore.categories.isEmpty {
                try await categoryStore.fetchAll()
            }
            
        } catch {
            
            print("Erreur load UserBookings : \(error)")
            
        }
        
    }

    // MARK: Rechargement de l'écran
    func refresh() async {
        
        do {
            
            try await reservationStore.fetchAll()
            
        } catch {
            
            print("Erreur refresh UserBookings : \(error)")
            
        }
        
    }

    // MARK: Annulation d'une réservation
    func cancel(_ reservation: Reservation) async {
        
        do {
            
            try await reservationStore.cancel(id: reservation.id)
            
        } catch {
            
            showsCancelError = true
            
        }
    }

    // MARK: Recherche + filtres, sur la liste déjà chargée
    private var visibleReservations: [Reservation] {
        
        reservationStore.reservations
            .filter { query.isEmpty || $0.workshop.name.localizedStandardContains(query) }
            .filter { matchesFilters($0) }
            .sorted { $0.workshop.startTime < $1.workshop.startTime }
        
    }

    private func matchesFilters(_ reservation: Reservation) -> Bool {

        // Formattage de la datte sélectionnée vu que les jours de l'API sont au format « 2026-09-03 » (UTC)
        let day = reservation.workshop.startTime.formatted(.iso8601.year().month().day())

        let matchesDay = filters.selectedPeriods.isEmpty || filters.selectedPeriods.contains(day)
        let matchesCategory = filters.selectedCategories.isEmpty || filters.selectedCategories.contains(reservation.workshop.categoryName)
        let matchesAvailability = filters.selectedAvailability == nil || filters.selectedAvailability == reservation.workshop.availability

        return matchesDay && matchesCategory && matchesAvailability
        
    }
}
