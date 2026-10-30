//
//  ReservationStore.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class ReservationStore {

    private(set) var reservations: [Reservation] = []
    private let service: ReservationService

    init(service: ReservationService) {
        self.service = service
    }

    func fetchAll() async throws {
        reservations = try await service.fetchAll()
    }

    func create(workshopID: UUID) async throws -> Reservation {
        let reservation = try await service.create(workshopID: workshopID)
        reservations.append(reservation)
        return reservation
    }

    func cancel(id: Int) async throws {
        let cancelled = try await service.cancel(id: id)
        if let index = reservations.firstIndex(where: { $0.id == id }) {
            reservations[index] = cancelled
        }
    }

    func reservation(for workshopID: UUID) -> Reservation? {
        reservations.first { $0.workshop.id == workshopID && $0.status != .cancelled }
    }
}
