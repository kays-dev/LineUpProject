import Fluent
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

    @Test("POST back-office : le staff réserve pour un festivalier")
    func staffBooksForFestivalgoer() async throws {
        try await withApp { app in
            let user = try await createFestivalgoer(app)
            let category = try await createCategory(app, name: "Théâtre")
            let workshop = try await createWorkshop(app, categoryID: category.id)
            let token = try makeToken(role: .staff)

            try await app.testing().test(.POST, "backoffice/reservations", beforeRequest: { req in
                req.headers.add(name: .xForwardedFor, value: "127.0.0.1")
                req.headers.add(name: .authorization, value: "Bearer \(token)")
                try req.content.encode(BackofficeCreateReservationsDTO(userID: user.id, workshopID: workshop.id))
            }, afterResponse: { res in
                #expect(res.status == .ok)
                let reservation = try res.content.decode(ReservationsResponseDTO.self)
                #expect(reservation.userName == user.name)
                #expect(reservation.workshop.id == workshop.id)
                #expect(reservation.workshop.remainingPlaces == 9)
                #expect(reservation.status == .validated)
            })
        }
    }

    @Test("POST back-office : impossible de réserver pour un compte staff")
    func staffCannotBookForStaff() async throws {
        try await withApp { app in
            let staff = Users(name: "Staff Test", email: "staff.test@lineup.com", passwordHash: "hash", role: .staff)
            try await staff.save(on: app.db)
            let category = try await createCategory(app, name: "Théâtre")
            let workshop = try await createWorkshop(app, categoryID: category.id)
            let token = try makeToken(role: .staff)

            try await app.testing().test(.POST, "backoffice/reservations", beforeRequest: { req in
                req.headers.add(name: .xForwardedFor, value: "127.0.0.1")
                req.headers.add(name: .authorization, value: "Bearer \(token)")
                try req.content.encode(BackofficeCreateReservationsDTO(userID: try staff.requireID(), workshopID: workshop.id))
            }, afterResponse: { res in
                #expect(res.status == .conflict)
            })
        }
    }

    @Test("Suppression d'un compte : sa place est libérée et la file d'attente avance")
    func releasePlacesPromotesWaitingUser() async throws {
        try await withApp { app in
            let leaving = try await createFestivalgoer(app)
            let waiting = Users(name: "Luca Galletti", email: "luca@example.com", passwordHash: "hash")
            try await waiting.save(on: app.db)
            let category = try await createCategory(app, name: "Théâtre")
            let startTime = Date().addingTimeInterval(3600 * 24)
            let workshop = Workshops(
                name: "Atelier poterie",
                startTime: startTime,
                endTime: startTime.addingTimeInterval(3600 * 2),
                capacityMax: 1,
                subscriberNumber: 0,
                workshopDescription: "Initiation au tour.",
                categoryID: category.id
            )
            try await workshop.save(on: app.db)
            let workshopID = try workshop.requireID()

            let first = try await createReservation(app, userID: leaving.id, workshopID: workshopID)
            let second = try await createReservation(app, userID: try waiting.requireID(), workshopID: workshopID)
            #expect(first.status == .validated)
            #expect(second.status == .pending)

            try await ReservationsController.releasePlaces(ofUser: leaving.id, on: app.db)

            let cancelled = try await Reservations.find(first.reservationID, on: app.db)
            let promoted = try await Reservations.find(second.reservationID, on: app.db)
            let updatedWorkshop = try await Workshops.find(workshopID, on: app.db)
            #expect(cancelled?.status == .cancelled)
            #expect(promoted?.status == .validated)
            #expect(updatedWorkshop?.subscriberNumber == 1)
        }
    }
}
