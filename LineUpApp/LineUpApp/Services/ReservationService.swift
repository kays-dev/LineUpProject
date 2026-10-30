//
//  ReservationService.swift
//  LineUpApp
//
//  Created by Apprenant174 on 26/10/2026.
//

import Foundation

struct ReservationService {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchAll() async throws -> [Reservation] {
        let response: [ReservationResponse] = try await apiClient.request(path: "appios/reservations")
        return response.map { $0.toModel() }
    }

    func fetchOne(id: Int) async throws -> Reservation {
        let response: ReservationResponse = try await apiClient.request(path: "appios/reservations/\(id)")
        return response.toModel()
    }

    func create(workshopID: UUID) async throws -> Reservation {
        let response: ReservationResponse = try await apiClient.request(
            path: "appios/reservations",
            method: .post,
            body: ReservationRequest(workshopID: workshopID)
        )
        return response.toModel()
    }

    func cancel(id: Int) async throws -> Reservation {
        let response: ReservationResponse = try await apiClient.request(
            path: "appios/reservations/\(id)/cancel",
            method: .patch
        )
        return response.toModel()
    }
}
