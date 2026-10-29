import Foundation
import Testing
import VaporTesting
@testable import LineUpAPI

// D du CRUD : supprimer une réservation (DELETE)

extension LineUpAPITests {

    // Réserve un atelier par l'API avec le token du festivalier et renvoie la réponse décodée
    func createReservation(_ app: Application, userID: UUID, workshopID: UUID) async throws -> ReservationsResponseDTO {
        let token = try makeToken(id: userID, role: .festivalgoer)
        let res = try await app.testing().sendRequest(.POST, "appios/reservations", beforeRequest: { req in
            req.headers.add(name: .xForwardedFor, value: "127.0.0.1")
            req.headers.add(name: .authorization, value: "Bearer \(token)")
            try req.content.encode(CreateReservationsDTO(workshopID: workshopID))
        })
        return try res.content.decode(ReservationsResponseDTO.self)
    }

    @Test("DELETE répond 204, puis la réservation n'existe plus")
    func deleteReservationThenNotFound() async throws {
        try await withApp { app in
            // Arrange : préparer
            let user = try await createFestivalgoer(app)
            let category = try await createCategory(app, name: "Théâtre")
            let workshop = try await createWorkshop(app, categoryID: category.id)
            let reservation = try await createReservation(app, userID: user.id, workshopID: workshop.id)
            let token = try makeToken(role: .staff)

            // Act : agir
            try await app.testing().test(.DELETE, "backoffice/reservations/\(reservation.reservationID)", beforeRequest: { req in
                req.headers.add(name: .xForwardedFor, value: "127.0.0.1")
                req.headers.add(name: .authorization, value: "Bearer \(token)")
            }, afterResponse: { res in
                // Assert : vérifier
                #expect(res.status == .noContent)
            })

            // Une réponse 204 ne suffit pas : on vérifie que la réservation a vraiment disparu
            try await app.testing().test(.GET, "backoffice/reservations/\(reservation.reservationID)", beforeRequest: { req in
                req.headers.add(name: .xForwardedFor, value: "127.0.0.1")
                req.headers.add(name: .authorization, value: "Bearer \(token)")
            }, afterResponse: { res in
                #expect(res.status == .notFound)
            })
        }
    }
}
