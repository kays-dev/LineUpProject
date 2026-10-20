@testable import LineUpAPI
import Fluent
import Foundation
import Testing
import VaporTesting

extension LineUpAPITests {
    @Test("Réservations : POST utilise userID fourni et approuve si une place est disponible")
    func createReservationUsesProvidedUserID() async throws {
        try await withApp { app in
            let fixture = try await makeReservationFixture(on: app)
            let workshopID = try fixture.workshop.requireID()
            let otherUser = User(
                name: "Autre compte",
                email: "other-reservation@example.test",
                password_hash: "hash-de-test",
                role: .festivalgoer
            )
            try await otherUser.create(on: app.db)

            let userID = try otherUser.requireID()

            let input = ReservationClientInput(
                workshopID: workshopID,
                userID: userID,
                status: "pending"
            )
            try await app.testing().test(
                .POST, "reservations",
                beforeRequest: { req in
                    try req.content.encode(input)
                },
                afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let output = try res.content.decode(ReservationResponseDTO.self)
                    #expect(output.status == .approved)
                    #expect(output.workshopID == workshopID)

                    let saved = try #require(
                        try await Reservation.find(output.reservationID, on: app.db)
                    )
                    #expect(saved.$user.id == userID)
                    #expect(saved.$workshop.id == workshopID)
                    #expect(saved.status == .approved)
                    let workshop = try #require(
                        try await Workshop.find(workshopID, on: app.db)
                    )
                    #expect(workshop.subscriber_number == 1)
                    #expect(try await Reservation.query(on: app.db).count() == 1)
                }
            )
        }
    }

    @Test("Réservations : POST approuve quand il reste exactement une place")
    func createReservationApprovesLastAvailablePlace() async throws {
        try await withApp { app in
            let fixture = try await makeReservationFixture(on: app)
            fixture.workshop.subscriber_number = fixture.workshop.capacity_max - 1
            try await fixture.workshop.update(on: app.db)

            let userID = try fixture.user.requireID()
            let workshopID = try fixture.workshop.requireID()

            try await app.testing().test(
                .POST, "reservations",
                beforeRequest: { req in
                    try req.content.encode(CreateReservationDTO(userID: userID, workshopID: workshopID))
                },
                afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let output = try res.content.decode(ReservationResponseDTO.self)
                    #expect(output.status == .approved)

                    let saved = try #require(
                        try await Reservation.find(output.reservationID, on: app.db)
                    )
                    #expect(saved.status == .approved)
                    let workshop = try #require(
                        try await Workshop.find(workshopID, on: app.db)
                    )
                    #expect(workshop.subscriber_number == workshop.capacity_max)
                }
            )
        }
    }

    @Test("Réservations : POST met en attente quand l'atelier est complet malgré le statut demandé")
    func createReservationWaitsWhenWorkshopIsFull() async throws {
        try await withApp { app in
            let fixture = try await makeReservationFixture(on: app)
            fixture.workshop.subscriber_number = fixture.workshop.capacity_max
            try await fixture.workshop.update(on: app.db)

            let userID = try fixture.user.requireID()
            let workshopID = try fixture.workshop.requireID()
            let input = ReservationClientInput(
                workshopID: workshopID,
                userID: userID,
                status: "approved"
            )

            try await app.testing().test(
                .POST, "reservations",
                beforeRequest: { req in
                    try req.content.encode(input)
                },
                afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let output = try res.content.decode(ReservationResponseDTO.self)
                    #expect(output.status == .pending)

                    let saved = try #require(
                        try await Reservation.find(output.reservationID, on: app.db)
                    )
                    #expect(saved.status == .pending)
                    let workshop = try #require(
                        try await Workshop.find(workshopID, on: app.db)
                    )
                    #expect(workshop.subscriber_number == workshop.capacity_max)
                    #expect(try await Reservation.query(on: app.db).count() == 1)
                }
            )
        }
    }

    @Test("Réservations : la dernière place approuvée met la demande suivante en attente")
    func createReservationKeepsCounterForWaitingRequest() async throws {
        try await withApp { app in
            let fixture = try await makeReservationFixture(on: app)
            fixture.workshop.capacity_max = 1
            try await fixture.workshop.update(on: app.db)

            let otherUser = User(
                name: "Compte en attente",
                email: "waiting-reservation@example.test",
                password_hash: "hash-de-test",
                role: .festivalgoer
            )
            try await otherUser.create(on: app.db)

            let workshopID = try fixture.workshop.requireID()
            let userID = try fixture.user.requireID()
            let otherUserID = try otherUser.requireID()
            let requests: [(UUID, ReservationStatus)] = [
                (userID, .approved),
                (otherUserID, .pending)
            ]

            for (requestUserID, expectedStatus) in requests {
                try await app.testing().test(
                    .POST, "reservations",
                    beforeRequest: { req in
                        try req.content.encode(CreateReservationDTO(userID: requestUserID, workshopID: workshopID))
                    },
                    afterResponse: { res async throws in
                        #expect(res.status == .ok)
                        #expect(try res.content.decode(ReservationResponseDTO.self).status == expectedStatus)
                        let workshop = try #require(
                            try await Workshop.find(workshopID, on: app.db)
                        )
                        let approvedCount = try await Reservation.query(on: app.db)
                            .filter(\.$workshop.$id == workshopID)
                            .filter(\.$status == .approved)
                            .count()
                        #expect(workshop.subscriber_number == 1)
                        #expect(workshop.subscriber_number == approvedCount)
                    }
                )
            }
        }
    }

    @Test("Réservations : POST doit recevoir userID dans le JSON")
    func createReservationRequiresUserID() async throws {
        try await withApp { app in
            try await app.testing().test(
                .POST, "reservations",
                beforeRequest: { req in
                    try req.content.encode(ReservationMissingUserInput(workshopID: UUID()))
                },
                afterResponse: { res async throws in
                    #expect(res.status == .badRequest)
                    #expect(try await Reservation.query(on: app.db).count() == 0)
                }
            )
        }
    }

    @Test("Réservations : POST pour un utilisateur inexistant est refusé")
    func createReservationRejectsUnknownUser() async throws {
        try await withApp { app in
            let fixture = try await makeReservationFixture(on: app)
            let workshopID = try fixture.workshop.requireID()

            try await app.testing().test(
                .POST, "reservations",
                beforeRequest: { req in
                    try req.content.encode(CreateReservationDTO(userID: UUID(), workshopID: workshopID))
                },
                afterResponse: { res async throws in
                    #expect(res.status == .notFound)
                    #expect(try await Reservation.query(on: app.db).count() == 0)
                }
            )
        }
    }

    @Test("Réservations : POST pour un atelier inexistant est refusé")
    func createReservationRejectsUnknownWorkshop() async throws {
        try await withApp { app in
            let fixture = try await makeReservationFixture(on: app)
            let userID = try fixture.user.requireID()

            try await app.testing().test(
                .POST, "reservations",
                beforeRequest: { req in
                    try req.content.encode(CreateReservationDTO(userID: userID, workshopID: UUID()))
                },
                afterResponse: { res async throws in
                    #expect(res.status == .notFound)
                    #expect(try await Reservation.query(on: app.db).count() == 0)
                }
            )
        }
    }

    func makeReservationFixture(on app: Application) async throws -> (
        user: User, workshop: Workshop
    ) {
        let user = User(
            name: "Compte réservation",
            email: "reservation@example.test",
            password_hash: "hash-de-test",
            role: .festivalgoer
        )
        try await user.create(on: app.db)

        let category = Category(name: "Cinéma")
        try await category.create(on: app.db)

        let startTime = Date()
        let workshop = Workshop(
            name: "Atelier réservation",
            start_time: startTime,
            end_time: startTime.addingTimeInterval(3600),
            capacity_max: 20,
            subscriber_number: 0,
            workshop_description: "Atelier pour tester la création d'une réservation.",
            categoryID: try category.requireID()
        )
        try await workshop.create(on: app.db)

        return (user, workshop)
    }
}

private struct ReservationClientInput: Content {
    let workshopID: UUID
    let userID: UUID
    let status: String
}

private struct ReservationMissingUserInput: Content {
    let workshopID: UUID
}
