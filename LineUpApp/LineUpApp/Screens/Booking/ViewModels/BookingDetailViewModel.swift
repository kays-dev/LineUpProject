//
//  BookingDetailViewModel.swift
//  LineUpApp
//
//  Created by Apprenant174 on 02/11/2026.
//

import Foundation

// Logique du détail d'une réservation : ce qu'on affiche selon le statut, annulation
@Observable
@MainActor
final class BookingDetailViewModel {

    let reservation: Reservation
    var showsCancelError = false

    private let reservationStore: ReservationStore

    // Nom de la section dans la description de l'API (« Consigne PSH|… »), à caler avec le back-office
    private let accessibilitySectionName = "Consigne PSH"

    init(reservation: Reservation, reservationStore: ReservationStore) {
        self.reservation = reservation
        self.reservationStore = reservationStore
    }

    var workshop: Workshop {
        reservation.workshop
    }

    var isWaiting: Bool {
        reservation.status == .pending
    }

    var canCancel: Bool {
        reservation.status != .cancelled && !reservation.isPast
    }

    var schedule: String {
        workshop.startTime.scheduleText(until: workshop.endTime)
    }

    var duration: String {
        workshop.startTime.durationText(until: workshop.endTime)
    }

    var accessibilityInstructions: String? {
        workshop.descriptionSection(name: accessibilitySectionName)?.detail
    }

    var progressLevels: ProgressBar.Levels {
        reservation.status == .cancelled ? .three : .two
    }

    var shareText: String {
        String(localized: .bookingNumber(reservation.code)) + " · " + workshop.name
    }

    // Renvoie true si l'annulation a réussi (l'écran revient alors à l'Agenda)
    func cancel() async -> Bool {
        do {
            try await reservationStore.cancel(id: reservation.id)
            return true
        } catch {
            showsCancelError = true
            return false
        }
    }
}
