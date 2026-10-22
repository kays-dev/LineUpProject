import Fluent
import Vapor

struct ReservationsController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let reservations = routes.grouped("reservations")
        reservations.post(use: create)
        reservations.get(use: myReservations)
        reservations.get(":reservationID", use: show)
        reservations.patch(":reservationID", "cancel", use: cancel)

        let backOffice = routes.grouped("backoffice", "reservations")

        backOffice.get(use: index)
        backOffice.get(":reservationID", use: show)
        backOffice.patch(":reservationID", "cancel", use: cancel)
        backOffice.patch(":reservationID", "status", use: updateStatus)
        backOffice.delete(":reservationID", use: delete)
        backOffice.patch("workshop", ":workshopID", "cancel", use: cancelForWorkshop)
        backOffice.delete("workshop", ":workshopID", use: deleteForWorkshop)
    }

    func create(req: Request) async throws -> ReservationsResponseDTO {
        let dto = try req.content.decode(CreateReservationsDTO.self)

        return try await req.db.transaction { db in
            let workshop = try await fetchWorkshop(dto.workshopID, on: db)
            guard try await Users.find(dto.userID, on: db) != nil else {
                throw Abort(.notFound, reason: "Utilisateur introuvable.")
            }

            try await ensureNoActiveReservation(userID: dto.userID, workshopID: dto.workshopID, on: db)

            // Les personnes déjà en attente passent avant cette nouvelle demande.
            try await promoteWaitingReservations(for: workshop, on: db)

            let status: ReservationStatus
            if workshop.subscriber_number < workshop.capacity_max {
                status = .validated
            } else {
                status = .pending
            }

            // Chaque demande crée une nouvelle ligne : son id auto-incrémenté donne sa place dans la file.
            let reservation = dto.toModel(status: status)
            try await reservation.create(on: db)

            if status == .validated {
                workshop.subscriber_number += 1
                try await workshop.update(on: db)
            }

            try await reservation.$workshop.load(on: db)
            try await reservation.$user.load(on: db)
            return try reservation.toDTO()
        }
    }

    // Sélection par userID fourni dans l'URL, sans contrôle d'identité.
    func myReservations(req: Request) async throws -> [ReservationsResponseDTO] {
        let filters = try req.query.decode(ReservationsQueryDTO.self)

        guard filters.userID != nil else {
            throw Abort(.badRequest, reason: "Le paramètre userID est obligatoire.")
        }

        return try await filteredReservations(filters, on: req.db)
    }

    // Consultation globale avec un filtre utilisateur facultatif.
    func index(req: Request) async throws -> [ReservationsResponseDTO] {
        let filters = try req.query.decode(ReservationsQueryDTO.self)
        return try await filteredReservations(filters, on: req.db)
    }

    func show(req: Request) async throws -> ReservationsResponseDTO {
        let reservation = try await fetchReservation(req)
        return try reservation.toDTO()
    }

    // Une annulation conserve la réservation et son identifiant en base.
    func cancel(req: Request) async throws -> ReservationsResponseDTO {
        let reservation = try await fetchReservation(req)

        return try await req.db.transaction { db in
            let workshop = try await fetchWorkshop(reservation.$workshop.id, on: db)

            guard reservation.status != .cancelled else {
                throw Abort(.conflict, reason: "La réservation est déjà annulée.")
            }

            let wasValidated = reservation.status == .validated
            if wasValidated {
                workshop.subscriber_number -= 1
                try await workshop.update(on: db)
            }

            reservation.status = .cancelled
            try await reservation.update(on: db)

            if wasValidated {
                try await promoteWaitingReservations(for: workshop, on: db)
            }

            return try reservation.toDTO()
        }
    }

    func updateStatus(req: Request) async throws -> ReservationsResponseDTO {
        let reservation = try await fetchReservation(req)

        return try await req.db.transaction { db in
            let workshop = try await fetchWorkshop(reservation.$workshop.id, on: db)

            let dto = try req.content.decode(UpdateReservationsDTO.self)

            // Une réservation annulée est définitive : pour revenir, l'utilisateur en crée une nouvelle.
            guard reservation.status != .cancelled else {
                throw Abort(.conflict, reason: "La réservation est annulée. Créez une nouvelle réservation.")
            }

            // Pour retirer une personne inscrite, le staff annule sa réservation.
            if reservation.status == .validated && dto.status == .pending {
                throw Abort(.conflict, reason: "Une réservation validée ne peut pas repasser en attente. Annulez-la plutôt.")
            }

            if reservation.status != .validated && dto.status == .validated {
                guard workshop.subscriber_number < workshop.capacity_max else {
                    throw Abort(.conflict, reason: "L'atelier est complet.")
                }

                let firstWaiting = try await Reservations.query(on: db)
                    .filter(\.$workshop.$id == reservation.$workshop.id)
                    .filter(\.$status == .pending)
                    .sort(\.$id, .ascending)
                    .first()
                guard firstWaiting == nil || firstWaiting?.id == reservation.id else {
                    throw Abort(.conflict, reason: "Une réservation plus ancienne est prioritaire.")
                }

                workshop.subscriber_number += 1
                try await workshop.update(on: db)
            } else if reservation.status == .validated && dto.status != .validated {
                workshop.subscriber_number -= 1
                try await workshop.update(on: db)
            }

            reservation.status = dto.status
            try await reservation.update(on: db)

            try await promoteWaitingReservations(for: workshop, on: db)

            // La promotion peut avoir changé le statut : on relit la réservation.
            guard let saved = try await Reservations.query(on: db)
                .filter(\.$id == reservation.requireID())
                .with(\.$workshop)
                .with(\.$user)
                .first() else {
                throw Abort(.notFound, reason: "Réservation introuvable.")
            }
            return try saved.toDTO()
        }
    }

    // Suppression définitive d'une seule réservation via l'URL du back-office.
    func delete(req: Request) async throws -> HTTPStatus {
        let reservation = try await fetchReservation(req)

        return try await req.db.transaction { db in
            let workshop = try await fetchWorkshop(reservation.$workshop.id, on: db)

            let wasValidated = reservation.status == .validated
            if wasValidated {
                workshop.subscriber_number -= 1
                try await workshop.update(on: db)
            }

            try await reservation.delete(on: db)
            if wasValidated {
                try await promoteWaitingReservations(for: workshop, on: db)
            }
            return HTTPStatus.noContent
        }
    }

    func cancelForWorkshop(req: Request) async throws -> HTTPStatus {
        guard let workshopID = req.parameters.get("workshopID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Identifiant d'atelier invalide.")
        }

        return try await req.db.transaction { db in
            let workshop = try await fetchWorkshop(workshopID, on: db)

            try await Reservations.query(on: db)
                .filter(\.$workshop.$id == workshopID)
                .set(\.$status, to: .cancelled)
                .update()

            workshop.subscriber_number = 0
            try await workshop.update(on: db)

            return HTTPStatus.noContent
        }
    }

    // Supprime les réservations de l'atelier, sans supprimer l'atelier lui-même.
    func deleteForWorkshop(req: Request) async throws -> HTTPStatus {
        guard let workshopID = req.parameters.get("workshopID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Identifiant d'atelier invalide.")
        }

        return try await req.db.transaction { db in
            let workshop = try await fetchWorkshop(workshopID, on: db)

            try await Reservations.query(on: db)
                .filter(\.$workshop.$id == workshopID)
                .delete()

            workshop.subscriber_number = 0
            try await workshop.update(on: db)

            return HTTPStatus.noContent
        }
    }

    // Lit l'identifiant de l'URL et charge la réservation avec son atelier et son utilisateur
    // (400 si invalide, 404 si absente).
    private func fetchReservation(_ req: Request) async throws -> Reservations {
        guard let reservationID = req.parameters.get("reservationID", as: Int.self) else {
            throw Abort(.badRequest, reason: "Identifiant de réservation invalide.")
        }
        guard let reservation = try await Reservations.query(on: req.db)
            .filter(\.$id == reservationID)
            .with(\.$workshop)
            .with(\.$user)
            .first() else {
            throw Abort(.notFound, reason: "Réservation introuvable.")
        }
        return reservation
    }

    // Charge l'atelier d'une réservation (404 s'il n'existe pas).
    private func fetchWorkshop(_ workshopID: UUID, on db: any Database) async throws -> Workshops {
        guard let workshop = try await Workshops.find(workshopID, on: db) else {
            throw Abort(.notFound, reason: "Atelier introuvable.")
        }
        return workshop
    }

    // Refuse une deuxième réservation non annulée du même utilisateur sur le même atelier (409).
    private func ensureNoActiveReservation(userID: UUID, workshopID: UUID, on db: any Database) async throws {
        let existingReservation = try await Reservations.query(on: db)
            .filter(\.$user.$id == userID)
            .filter(\.$workshop.$id == workshopID)
            .filter(\.$status != .cancelled)
            .first()

        guard existingReservation == nil else {
            throw Abort(.conflict, reason: "Vous avez déjà une réservation active pour cet atelier.")
        }
    }

    // Filtres communs aux listes mobile et back-office, triés par ordre d'arrivée (id croissant).
    private func filteredReservations(_ filters: ReservationsQueryDTO, on db: any Database) async throws -> [ReservationsResponseDTO] {
        let query = Reservations.query(on: db)
            .with(\.$workshop)
            .with(\.$user)

        if let userID = filters.userID {
            query.filter(\.$user.$id == userID)
        }
        if let status = filters.status {
            query.filter(\.$status == status)
        }
        if let workshopID = filters.workshopID {
            query.filter(\.$workshop.$id == workshopID)
        }
        if let name = filters.name, !name.isEmpty {
            query
                .join(parent: \.$workshop)
                .filter(Workshops.self, \.$name ~~ name)
        }

        let reservations = try await query
            .sort(\.$id, .ascending).all()
        return try reservations.map { try $0.toDTO() }
    }

    // Promotion automatique : tant qu'il reste des places, la plus ancienne réservation
    // en attente (plus petit id) passe en validated et le compteur de l'atelier augmente.
    // À appeler dans la transaction qui a modifié le compteur de l'atelier.
    private func promoteWaitingReservations(for workshop: Workshops, on db: any Database) async throws {
        let workshopID = try workshop.requireID()
        while workshop.subscriber_number < workshop.capacity_max {
            guard let next = try await Reservations.query(on: db)
                .filter(\.$workshop.$id == workshopID)
                .filter(\.$status == .pending)
                .sort(\.$id, .ascending)
                .first() else {
                break
            }

            next.status = .validated
            try await next.update(on: db)
            workshop.subscriber_number += 1
            try await workshop.update(on: db)
        }
    }

    // Hausse de places d'un atelier : Imane l'appellera depuis WorkshopsController.update,
    // juste après avoir enregistré la nouvelle capacity_max :
    //     try await ReservationsController.promoteAfterCapacityIncrease(for: workshop, on: req.db)
    // Les personnes en attente passent en validated, dans l'ordre d'arrivée, tant qu'il reste des places.
    // static : appelable depuis un autre controller sans créer de ReservationsController.
    static func promoteAfterCapacityIncrease(for workshop: Workshops, on db: any Database) async throws {
        try await db.transaction { db in
            try await ReservationsController().promoteWaitingReservations(for: workshop, on: db)
        }
    }
}
