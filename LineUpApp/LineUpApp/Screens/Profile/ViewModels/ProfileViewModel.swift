//
//  ProfileViewModel.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation

@Observable
@MainActor
final class ProfileViewModel {

    var isLoading = false
    var hasError = false

    private let reservationStore: ReservationStore
    private let workshopStore: WorkshopStore
    private let secondsPerHour: TimeInterval = 3600
    private let placeSectionName = "Lieu"

    init(reservationStore: ReservationStore, workshopStore: WorkshopStore) {
        self.reservationStore = reservationStore
        self.workshopStore = workshopStore
    }

    var history: [Reservation] {
        attendedReservations.sorted { $0.workshop.startTime > $1.workshop.startTime }
    }

    var reservationCount: Int {
        activeReservations.count
    }

    var attendedCount: Int {
        attendedReservations.count
    }

    var hoursSpent: Int {
        var seconds: TimeInterval = 0
        for reservation in attendedReservations {
            seconds += reservation.workshop.endTime.timeIntervalSince(reservation.workshop.startTime)
        }
        return Int((seconds / secondsPerHour).rounded())
    }

    var hoursSpentText: String {
        Measurement(value: Double(hoursSpent), unit: UnitDuration.hours)
            .formatted(.measurement(width: .narrow))
    }

    var favoriteCategory: String? {
        var counts: [String: Int] = [:]
        for reservation in activeReservations {
            counts[reservation.workshop.categoryName, default: 0] += 1
        }
        return counts.max { first, second in
            if first.value == second.value {
                return first.key > second.key
            }
            return first.value < second.value
        }?.key
    }

    var festivalDaysCount: Int {
        var days: Set<Date> = []
        for reservation in validatedReservations {
            days.insert(Calendar.current.startOfDay(for: reservation.workshop.startTime))
        }
        return days.count
    }

    var festivalDaysText: String {
        "\(festivalDaysCount) / \(workshopStore.workshopDays.count)"
    }

    var placesVisitedCount: Int {
        var places: Set<String> = []
        for reservation in attendedReservations {
            if let place = reservation.workshop.descriptionSection(name: placeSectionName) {
                places.insert(place.detail)
            }
        }
        return places.count
    }

    func loadProfile() async {
        isLoading = true
        hasError = false
        defer { isLoading = false }
        do {
            try await reservationStore.fetchAll()
            try await workshopStore.fetchWorkshopsDays()
            for reservation in reservationStore.reservations {
                print(reservation)
            }
        } catch {
            hasError = true
            print("Erreur loadProfile : \(error)")
        }
    }

    private var activeReservations: [Reservation] {
        reservationStore.reservations.filter { $0.status != .cancelled }
    }

    private var validatedReservations: [Reservation] {
        reservationStore.reservations.filter { $0.status == .validated }
    }

    private var attendedReservations: [Reservation] {
        validatedReservations.filter { $0.isPast }
    }
}
