@testable import LineUpAPI
import Fluent
import Foundation
import Testing
import VaporTesting

extension LineUpAPITests {
    @Test("Mobile : liste, recherche et filtres sélectionnent le userID fourni")
    func mobileReservationSearch() async throws {
        try await withApp { app in
            let fixture = try await makeManagementFixture(on: app)
            let ownID = try fixture.own.requireID()
            let ownOtherID = try fixture.ownOtherWorkshop.requireID()
            let userID = try fixture.user.requireID()
            let otherUserID = try fixture.otherUser.requireID()
            let workshopID = try fixture.workshop.requireID()

            for path in ["reservations?userID=\(userID)", "reservations/search?userID=\(userID)"] {
                try await app.testing().test(.GET, path, afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let output = try res.content.decode([ReservationResponseDTO].self)
                    #expect(output.count == 2)
                    #expect(Set(output.map(\.reservationID)) == Set([ownID, ownOtherID]))
                })
            }

            let otherID = try fixture.other.requireID()
            let otherOtherID = try fixture.otherOtherWorkshop.requireID()
            try await app.testing().test(
                .GET, "reservations?userID=\(otherUserID)",
                afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let output = try res.content.decode([ReservationResponseDTO].self)
                    #expect(output.count == 2)
                    #expect(Set(output.map(\.reservationID)) == Set([otherID, otherOtherID]))
                }
            )

            try await app.testing().test(
                .GET, "reservations/search?userID=\(userID)&name=montage&status=pending&workshopID=\(workshopID)",
                afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let output = try res.content.decode([ReservationResponseDTO].self)
                    #expect(output.map(\.reservationID) == [ownID])
                }
            )
            try await app.testing().test(
                .GET, "reservations?userID=\(userID)&name=montage&status=approved",
                afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    #expect(try res.content.decode([ReservationResponseDTO].self).isEmpty)
                }
            )
        }
    }

    @Test("Mobile : consultation et annulation conservent la réservation en base")
    func mobileCancelsReservation() async throws {
        try await withApp { app in
            let fixture = try await makeManagementFixture(on: app)
            let reservationID = try fixture.own.requireID()

            try await app.testing().test(
                .GET, "reservations/\(reservationID)",
                afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    #expect(try res.content.decode(ReservationResponseDTO.self).reservationID == reservationID)
                }
            )
            // Répéter l'annulation doit laisser la ligne existante à cancelled.
            for _ in 0..<2 {
                try await app.testing().test(
                    .PATCH, "reservations/\(reservationID)/cancel",
                    afterResponse: { res async throws in
                        #expect(res.status == .ok)
                        let output = try res.content.decode(ReservationResponseDTO.self)
                        #expect(output.reservationID == reservationID)
                        #expect(output.status == .cancelled)
                        let workshop = try #require(
                            try await Workshop.find(fixture.workshop.id, on: app.db)
                        )
                        #expect(workshop.subscriber_number == 1)
                    }
                )
            }
            let saved = try #require(try await Reservation.find(reservationID, on: app.db))
            #expect(saved.status == .cancelled)
            #expect(try await Reservation.query(on: app.db).count() == 4)

            try await app.testing().test(
                .DELETE, "reservations/\(reservationID)",
                afterResponse: { res async in
                    #expect(res.status == .notFound)
                }
            )
            #expect(try await Reservation.query(on: app.db).count() == 4)
        }
    }

    @Test("Réservations : consultation et annulation par identifiant sans connexion")
    func reservationAccessWithoutConnection() async throws {
        try await withApp { app in
            let fixture = try await makeManagementFixture(on: app)
            let otherID = try fixture.other.requireID()

            for path in ["reservations/\(otherID)", "backoffice/reservations/\(otherID)"] {
                try await app.testing().test(.GET, path, afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    #expect(try res.content.decode(ReservationResponseDTO.self).reservationID == otherID)
                })
            }

            for _ in 0..<2 {
                try await app.testing().test(
                    .PATCH, "reservations/\(otherID)/cancel",
                    afterResponse: { res async throws in
                        #expect(res.status == .ok)
                        #expect(try res.content.decode(ReservationResponseDTO.self).status == .cancelled)
                        let workshop = try #require(
                            try await Workshop.find(fixture.workshop.id, on: app.db)
                        )
                        #expect(workshop.subscriber_number == 0)
                    }
                )
            }
            let other = try #require(try await Reservation.find(otherID, on: app.db))
            #expect(other.status == .cancelled)
            #expect(try await Reservation.query(on: app.db).count() == 4)
        }
    }

    @Test("Back-office : consultation globale, détail et filtres sans connexion")
    func backOfficeReservationSearch() async throws {
        try await withApp { app in
            let fixture = try await makeManagementFixture(on: app)
            let otherID = try fixture.other.requireID()
            let otherUserID = try fixture.otherUser.requireID()
            let workshopID = try fixture.workshop.requireID()

            try await app.testing().test(.GET, "backoffice/reservations", afterResponse: { res async throws in
                #expect(res.status == .ok)
                #expect(try res.content.decode([ReservationResponseDTO].self).count == 4)
            })
            try await app.testing().test(
                .GET, "backoffice/reservations/search?name=montage&status=approved&userID=\(otherUserID)&workshopID=\(workshopID)",
                afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let output = try res.content.decode([ReservationResponseDTO].self)
                    #expect(output.map(\.reservationID) == [otherID])
                }
            )
            for path in ["reservations/\(otherID)", "backoffice/reservations/\(otherID)"] {
                try await app.testing().test(.GET, path, afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    #expect(try res.content.decode(ReservationResponseDTO.self).reservationID == otherID)
                })
            }
        }
    }

    @Test("Back-office : modification du statut et refus d'une valeur inconnue")
    func backOfficeUpdatesReservationStatus() async throws {
        try await withApp { app in
            let fixture = try await makeManagementFixture(on: app)
            let reservationID = try fixture.otherOtherWorkshop.requireID()

            try await app.testing().test(
                .PATCH, "backoffice/reservations/\(reservationID)/status",
                beforeRequest: { req in
                    try req.content.encode(UpdateReservationDTO(status: .approved))
                },
                afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    #expect(try res.content.decode(ReservationResponseDTO.self).status == .approved)
                }
            )
            try await app.testing().test(
                .PATCH, "backoffice/reservations/\(reservationID)/status",
                beforeRequest: { req in
                    try req.content.encode(InvalidReservationStatusInput(status: "unknown"))
                },
                afterResponse: { res async in
                    #expect(res.status == .badRequest)
                }
            )
            let saved = try #require(try await Reservation.find(reservationID, on: app.db))
            #expect(saved.status == .approved)
            let workshop = try #require(
                try await Workshop.find(fixture.otherWorkshop.id, on: app.db)
            )
            #expect(workshop.subscriber_number == 2)
        }
    }

    @Test("Back-office : les transitions changent le compteur seulement en entrant ou sortant de approved")
    func backOfficeStatusTransitionsKeepCounter() async throws {
        try await withApp { app in
            let fixture = try await makeManagementFixture(on: app)
            let reservationID = try fixture.own.requireID()
            let workshopID = try fixture.workshop.requireID()
            let changes: [(ReservationStatus, Int)] = [
                (.approved, 2),
                (.approved, 2),
                (.pending, 1),
                (.pending, 1),
                (.cancelled, 1),
                (.approved, 2),
                (.cancelled, 1),
                (.cancelled, 1)
            ]

            for (status, expectedCount) in changes {
                try await app.testing().test(
                    .PATCH, "backoffice/reservations/\(reservationID)/status",
                    beforeRequest: { req in
                        try req.content.encode(UpdateReservationDTO(status: status))
                    },
                    afterResponse: { res async throws in
                        #expect(res.status == .ok)
                        #expect(try res.content.decode(ReservationResponseDTO.self).status == status)
                        let workshop = try #require(
                            try await Workshop.find(workshopID, on: app.db)
                        )
                        let approvedCount = try await Reservation.query(on: app.db)
                            .filter(\.$workshop.$id == workshopID)
                            .filter(\.$status == .approved)
                            .count()
                        #expect(workshop.subscriber_number == expectedCount)
                        #expect(workshop.subscriber_number == approvedCount)
                    }
                )
            }
        }
    }

    @Test("Back-office : annulation par atelier puis unitaire sans suppression")
    func backOfficeCancelsReservations() async throws {
        try await withApp { app in
            let fixture = try await makeManagementFixture(on: app)
            let otherID = try fixture.ownOtherWorkshop.requireID()
            let workshopID = try fixture.workshop.requireID()

            try await app.testing().test(
                .PATCH, "backoffice/reservations/workshop/\(workshopID)/cancel",
                afterResponse: { res async in
                    #expect(res.status == .noContent)
                }
            )
            let cancelled = try await Reservation.query(on: app.db)
                .filter(\.$workshop.$id == workshopID).all()
            #expect(cancelled.count == 2)
            #expect(cancelled.allSatisfy { $0.status == .cancelled })
            let unaffected = try #require(
                try await Reservation.find(fixture.ownOtherWorkshop.id, on: app.db)
            )
            #expect(unaffected.status == .approved)
            let workshop = try #require(try await Workshop.find(workshopID, on: app.db))
            let otherWorkshop = try #require(
                try await Workshop.find(fixture.otherWorkshop.id, on: app.db)
            )
            #expect(workshop.subscriber_number == 0)
            #expect(otherWorkshop.subscriber_number == 1)

            try await app.testing().test(
                .PATCH, "backoffice/reservations/\(otherID)/cancel",
                afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    #expect(try res.content.decode(ReservationResponseDTO.self).status == .cancelled)
                }
            )
            let updatedOtherWorkshop = try #require(
                try await Workshop.find(fixture.otherWorkshop.id, on: app.db)
            )
            #expect(updatedOtherWorkshop.subscriber_number == 0)
            #expect(try await Reservation.query(on: app.db).count() == 4)
        }
    }

    @Test("Back-office : suppression définitive d'une réservation sans connexion")
    func backOfficeDeletesReservation() async throws {
        try await withApp { app in
            let fixture = try await makeManagementFixture(on: app)
            let otherID = try fixture.other.requireID()

            try await app.testing().test(
                .DELETE, "backoffice/reservations/\(otherID)",
                afterResponse: { res async in
                    #expect(res.status == .noContent)
                }
            )
            #expect(try await Reservation.find(otherID, on: app.db) == nil)
            #expect(try await Reservation.find(fixture.own.id, on: app.db) != nil)
            #expect(try await Reservation.query(on: app.db).count() == 3)
            let workshop = try #require(
                try await Workshop.find(fixture.workshop.id, on: app.db)
            )
            let otherWorkshop = try #require(
                try await Workshop.find(fixture.otherWorkshop.id, on: app.db)
            )
            #expect(workshop.subscriber_number == 0)
            #expect(otherWorkshop.subscriber_number == 1)
        }
    }

    @Test("Back-office : supprimer pending ou cancelled ne retire aucune place approuvée")
    func backOfficeDeletesNonApprovedWithoutChangingCounter() async throws {
        try await withApp { app in
            let fixture = try await makeManagementFixture(on: app)
            let pendingID = try fixture.own.requireID()
            let cancelledID = try fixture.otherOtherWorkshop.requireID()

            for reservationID in [pendingID, cancelledID] {
                try await app.testing().test(
                    .DELETE, "backoffice/reservations/\(reservationID)",
                    afterResponse: { res async in
                        #expect(res.status == .noContent)
                    }
                )
                #expect(try await Reservation.find(reservationID, on: app.db) == nil)
                let workshop = try #require(
                    try await Workshop.find(fixture.workshop.id, on: app.db)
                )
                let otherWorkshop = try #require(
                    try await Workshop.find(fixture.otherWorkshop.id, on: app.db)
                )
                #expect(workshop.subscriber_number == 1)
                #expect(otherWorkshop.subscriber_number == 1)
            }
            #expect(try await Reservation.query(on: app.db).count() == 2)
        }
    }

    @Test("Back-office : supprimer les réservations d'un atelier permet ensuite sa suppression")
    func backOfficeDeletesReservationsForWorkshop() async throws {
        try await withApp { app in
            let fixture = try await makeManagementFixture(on: app)
            let workshopID = try fixture.workshop.requireID()

            try await app.testing().test(
                .DELETE, "backoffice/reservations/workshop/\(workshopID)",
                afterResponse: { res async in
                    #expect(res.status == .noContent)
                }
            )
            #expect(try await Reservation.query(on: app.db)
                .filter(\.$workshop.$id == workshopID).count() == 0)
            #expect(try await Reservation.query(on: app.db).count() == 2)
            let workshop = try #require(try await Workshop.find(workshopID, on: app.db))
            let otherWorkshop = try #require(
                try await Workshop.find(fixture.otherWorkshop.id, on: app.db)
            )
            #expect(workshop.subscriber_number == 0)
            #expect(otherWorkshop.subscriber_number == 1)

            // Le futur WorkshopController pourra alors supprimer cet atelier.
            try await fixture.workshop.delete(on: app.db)
            #expect(try await Workshop.find(workshopID, on: app.db) == nil)
            #expect(try await Workshop.find(fixture.otherWorkshop.id, on: app.db) != nil)
        }
    }

    @Test("Listes : userID est obligatoire sur les URL mobiles et facultatif sur le back-office")
    func reservationListRequiresUserID() async throws {
        try await withApp { app in
            for path in ["reservations", "reservations/search?name=montage"] {
                try await app.testing().test(.GET, path, afterResponse: { res async in
                    #expect(res.status == .badRequest)
                })
            }
            try await app.testing().test(.GET, "backoffice/reservations", afterResponse: { res async throws in
                #expect(res.status == .ok)
                #expect(try res.content.decode([ReservationResponseDTO].self).isEmpty)
            })
        }
    }

    @Test("Paramètres : mauvais identifiants, filtres invalides et ressources absentes")
    func reservationParameterErrors() async throws {
        try await withApp { app in
            _ = try await makeManagementFixture(on: app)
            for path in ["reservations/not-a-uuid", "reservations?status=unknown", "reservations?workshopID=abc", "reservations?userID=abc"] {
                try await app.testing().test(.GET, path, afterResponse: { res async in
                    #expect(res.status == .badRequest)
                })
            }
            let unknownID = UUID()
            let absent: [(HTTPMethod, String)] = [
                (.GET, "reservations/\(unknownID)"),
                (.PATCH, "reservations/\(unknownID)/cancel"),
                (.PATCH, "backoffice/reservations/\(unknownID)/status"),
                (.DELETE, "backoffice/reservations/\(unknownID)"),
                (.PATCH, "backoffice/reservations/workshop/\(unknownID)/cancel"),
                (.DELETE, "backoffice/reservations/workshop/\(unknownID)")
            ]
            for (method, path) in absent {
                try await app.testing().test(method, path, afterResponse: { res async in
                    #expect(res.status == .notFound)
                })
            }
            #expect(try await Reservation.query(on: app.db).count() == 4)
        }
    }

    private func makeManagementFixture(on app: Application) async throws -> ReservationManagementFixture {
        let fixture = try await makeReservationFixture(on: app)
        fixture.workshop.name = "Cinéma montage"
        try await fixture.workshop.update(on: app.db)

        let otherUser = User(
            name: "Autre propriétaire",
            email: "management-other@example.test",
            password_hash: "hash-de-test",
            role: .festivalgoer
        )
        try await otherUser.create(on: app.db)
        let otherWorkshop = Workshop(
            name: "Musique",
            start_time: fixture.workshop.start_time,
            end_time: fixture.workshop.end_time,
            capacity_max: 20,
            subscriber_number: 0,
            workshop_description: "Deuxième atelier pour vérifier la portée des requêtes.",
            categoryID: fixture.workshop.$category.id
        )
        try await otherWorkshop.create(on: app.db)

        let userID = try fixture.user.requireID()
        let otherUserID = try otherUser.requireID()
        let workshopID = try fixture.workshop.requireID()
        let otherWorkshopID = try otherWorkshop.requireID()
        let own = Reservation(
            status: .pending,
            userID: userID,
            workshopID: workshopID
        )

        let ownOther = Reservation(
            status: .approved,
            userID: userID,
            workshopID: otherWorkshopID
        )

        let other = Reservation(
            status: .approved,
            userID: otherUserID,
            workshopID: workshopID
        )

        let otherOther = Reservation(
            status: .cancelled,
            userID: otherUserID,
            workshopID: otherWorkshopID
        )

        // Fluent attribue un UUID à chaque réservation lors de sa création.
        for reservation in [own, ownOther, other, otherOther] {
            try await reservation.create(on: app.db)
        }

        // Les données de départ contiennent une réservation approved par atelier.
        fixture.workshop.subscriber_number = 1
        try await fixture.workshop.update(on: app.db)
        otherWorkshop.subscriber_number = 1
        try await otherWorkshop.update(on: app.db)

        return ReservationManagementFixture(
            user: fixture.user, otherUser: otherUser,
            workshop: fixture.workshop, otherWorkshop: otherWorkshop,
            own: own, ownOtherWorkshop: ownOther,
            other: other, otherOtherWorkshop: otherOther
        )
    }
}

private struct ReservationManagementFixture {
    let user: User
    let otherUser: User
    let workshop: Workshop
    let otherWorkshop: Workshop
    let own: Reservation
    let ownOtherWorkshop: Reservation
    let other: Reservation
    let otherOtherWorkshop: Reservation
}

private struct InvalidReservationStatusInput: Content {
    let status: String
}
