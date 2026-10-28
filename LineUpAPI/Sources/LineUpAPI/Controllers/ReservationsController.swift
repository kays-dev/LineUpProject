import Fluent
import Vapor

struct ReservationsController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        // App iOS : festivalier connecté (token obligatoire)
        let appios = routes.grouped("appios", "reservations").grouped(JWTMiddleware())
        appios.post(use: create)
        appios.get(use: myReservations)
        appios.get(":reservationID", use: show)
        appios.patch(":reservationID", "cancel", use: cancel)

        // Back-office : staff uniquement
        let backoffice = routes.grouped("backoffice", "reservations").grouped(JWTMiddleware(), StaffMiddleware())
        backoffice.get(use: index)
        backoffice.get(":reservationID", use: show)
        backoffice.patch(":reservationID", "cancel", use: cancel)
        backoffice.patch(":reservationID", "status", use: updateStatus)
        backoffice.delete(":reservationID", use: delete)
        backoffice.patch("workshop", ":workshopID", "cancel", use: cancelForWorkshop)
        backoffice.delete("workshop", ":workshopID", use: deleteForWorkshop)
    }

    // Fonctions transversales (app iOS + back-office)

    // Détail d'une réservation : le festivalier ne voit que les siennes, le staff voit tout.
    func show(req: Request) async throws -> ReservationsResponseDTO {
        let reservation = try await fetchReservation(req)
        return try reservation.toDTO()
    }

    // Annule une réservation (la ligne reste en base) et libère sa place si elle était validée.
    func cancel(req: Request) async throws -> ReservationsResponseDTO {
        let reservation = try await fetchReservation(req)

        // Transaction : toutes les écritures sont enregistrées ensemble, ou aucune si une étape échoue.
        return try await req.db.transaction { db in
            let workshop = try await fetchWorkshop(reservation.$workshop.id, on: db)
            try ensureWorkshopNotEnded(workshop)

            guard reservation.status != .cancelled else {
                throw ReservationsError.cannotCancelAgain
            }

            let wasValidated = reservation.status == .validated
            if wasValidated {
                workshop.subscriberNumber -= 1
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

    // Fonctions de l'app iOS

    // Réserve un atelier pour le festivalier connecté : validée s'il reste une place, en attente sinon.
    func create(req: Request) async throws -> ReservationsResponseDTO {
        let payload = try req.auth.require(UsersPayload.self)
        let dto = try req.content.decode(CreateReservationsDTO.self)

        // Transaction : la réservation et le compteur de l'atelier sont enregistrés ensemble, ou pas du tout.
        return try await req.db.transaction { db in
            let workshop = try await fetchWorkshop(dto.workshopID, on: db)
            try ensureWorkshopNotEnded(workshop)

            guard try await Users.find(payload.id, on: db) != nil else {
                throw ReservationsError.noUser
            }

            try await ensureNoActiveReservation(userID: payload.id, workshopID: dto.workshopID, on: db)

            // Les personnes déjà en attente passent avant cette nouvelle demande.
            try await promoteWaitingReservations(for: workshop, on: db)

            let status: ReservationStatus
            if workshop.subscriberNumber < workshop.capacityMax {
                status = .validated
            } else {
                status = .pending
            }

            // Chaque demande crée une nouvelle ligne : son id auto-incrémenté donne sa place dans la file.
            let reservation = dto.toModel(status: status, userID: payload.id)
            try await reservation.create(on: db)

            if status == .validated {
                workshop.subscriberNumber += 1
                try await workshop.update(on: db)
            }

            try await reservation.$workshop.load(on: db)
            try await reservation.$user.load(on: db)
            return try reservation.toDTO()
        }
    }

    // Les réservations du festivalier connecté (id lu dans le token), par ordre d'arrivée.
    func myReservations(req: Request) async throws -> [ReservationsResponseDTO] {
        let payload = try req.auth.require(UsersPayload.self)

        let reservations = try await Reservations.query(on: req.db)
            .filter(\.$user.$id == payload.id)
            .with(\.$workshop)
            .with(\.$user)
            .sort(\.$id, .ascending)
            .all()
        return try reservations.map { try $0.toDTO() }
    }

    //  Fonctions du back-office

    // Toutes les réservations, par pages de 10.
    func index(req: Request) async throws -> Page<ReservationsResponseDTO> {
        let filters = try req.query.decode(ReservationsQueryDTO.self)

        let query = Reservations.query(on: req.db)
            .with(\.$workshop)
            .with(\.$user)

        if let status = filters.status {
            query.filter(\.$status == status)
        }
        if let workshopID = filters.workshop {
            query.filter(\.$workshop.$id == workshopID)
        }
        if let search = filters.search, !search.isEmpty {
            query
                .join(parent: \.$user)
                .group(.or) { group in
                    group.filter(Users.self, \.$name ~~ search)
                    group.filter(Users.self, \.$email ~~ search)
                }
        }

        let page = try await query
            .sort(\.$id, .ascending)
            .paginate(for: req)
        return try page.map { try $0.toDTO() }
    }

    // Le staff change le statut à la main, en respectant les places et l'ordre de la file.
    func updateStatus(req: Request) async throws -> ReservationsResponseDTO {
        let reservation = try await fetchReservation(req)

        // Transaction : la réservation et le compteur de l'atelier sont enregistrés ensemble, ou pas du tout.
        return try await req.db.transaction { db in
            let workshop = try await fetchWorkshop(reservation.$workshop.id, on: db)
            try ensureWorkshopNotEnded(workshop)

            let dto = try req.content.decode(UpdateReservationsDTO.self)

            // Une réservation annulée est définitive : pour revenir, l'utilisateur en crée une nouvelle.
            guard reservation.status != .cancelled else {
                throw ReservationsError.createToChange
            }

            // Pour retirer une personne inscrite, le staff annule sa réservation.
            if reservation.status == .validated && dto.status == .pending {
                throw ReservationsError.cancelToChange
            }

            if reservation.status != .validated && dto.status == .validated {
                guard workshop.subscriberNumber < workshop.capacityMax else {
                    throw ReservationsError.full
                }

                let firstWaiting = try await Reservations.query(on: db)
                    .filter(\.$workshop.$id == reservation.$workshop.id)
                    .filter(\.$status == .pending)
                    .sort(\.$id, .ascending)
                    .first()
                guard firstWaiting == nil || firstWaiting?.id == reservation.id else {
                    throw ReservationsError.notNextInLine
                }

                workshop.subscriberNumber += 1
                try await workshop.update(on: db)
            } else if reservation.status == .validated && dto.status != .validated {
                workshop.subscriberNumber -= 1
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
                throw ReservationsError.noReservation
            }
            return try saved.toDTO()
        }
    }

    // Suppression définitive d'une seule réservation via l'URL du back-office.
    func delete(req: Request) async throws -> HTTPStatus {
        let reservation = try await fetchReservation(req)

        // Transaction : la suppression et le compteur de l'atelier sont enregistrés ensemble, ou pas du tout.
        return try await req.db.transaction { db in
            let workshop = try await fetchWorkshop(reservation.$workshop.id, on: db)

            let wasValidated = reservation.status == .validated
            if wasValidated {
                workshop.subscriberNumber -= 1
                try await workshop.update(on: db)
            }

            try await reservation.delete(on: db)
            if wasValidated {
                try await promoteWaitingReservations(for: workshop, on: db)
            }
            return HTTPStatus.noContent
        }
    }

    // Annule toutes les réservations d'un atelier (par exemple si l'atelier est annulé).
    func cancelForWorkshop(req: Request) async throws -> HTTPStatus {
        guard let workshopID = req.parameters.get("workshopID", as: UUID.self) else {
            throw ReservationsError.invalidWorkshopID
        }

        // Transaction : les réservations et le compteur de l'atelier sont enregistrés ensemble, ou pas du tout.
        return try await req.db.transaction { db in
            let workshop = try await fetchWorkshop(workshopID, on: db)

            try await Reservations.query(on: db)
                .filter(\.$workshop.$id == workshopID)
                .set(\.$status, to: .cancelled)
                .update()

            workshop.subscriberNumber = 0
            try await workshop.update(on: db)

            return HTTPStatus.noContent
        }
    }

    // Supprime les réservations de l'atelier, sans supprimer l'atelier lui-même.
    func deleteForWorkshop(req: Request) async throws -> HTTPStatus {
        guard let workshopID = req.parameters.get("workshopID", as: UUID.self) else {
            throw ReservationsError.invalidWorkshopID
        }

        // Transaction : les suppressions et le compteur de l'atelier sont enregistrés ensemble, ou pas du tout.
        return try await req.db.transaction { db in
            let workshop = try await fetchWorkshop(workshopID, on: db)

            try await Reservations.query(on: db)
                .filter(\.$workshop.$id == workshopID)
                .delete()

            workshop.subscriberNumber = 0
            try await workshop.update(on: db)

            return HTTPStatus.noContent
        }
    }

    // accès à partir de la fonction update du worskhop controller
    static func promoteAfterCapacityIncrease(
        for workshop: Workshops,
        on db: any Database
    ) async throws {
        try await ReservationsController()
            .promoteWaitingReservations(for: workshop, on: db)
    }

    // Helpers 

    // Charge la réservation de l'URL avec son atelier et son utilisateur.
    // 400 si l'id est invalide ; 404 si elle n'existe pas ou n'appartient pas au festivalier connecté.
    private func fetchReservation(_ req: Request) async throws -> Reservations {
        let payload = try req.auth.require(UsersPayload.self)

        guard let reservationID = req.parameters.get("reservationID", as: Int.self) else {
            throw ReservationsError.invalidID
        }
        guard let reservation = try await Reservations.query(on: req.db)
            .filter(\.$id == reservationID)
            .with(\.$workshop)
            .with(\.$user)
            .first() else {
            throw ReservationsError.noReservation
        }

        // Un festivalier ne doit pas savoir qu'une réservation d'un autre existe : même réponse 404.
        guard payload.role == .staff || reservation.$user.id == payload.id else {
            throw ReservationsError.noReservation
        }
        return reservation
    }

    // Charge l'atelier d'une réservation (404 s'il n'existe pas).
    private func fetchWorkshop(_ workshopID: UUID, on db: any Database) async throws -> Workshops {
        guard let workshop = try await Workshops.find(workshopID, on: db) else {
            throw ReservationsError.noWorkshop
        }
        return workshop
    }

    // Refuse toute action sur un atelier déjà terminé (409).
    private func ensureWorkshopNotEnded(_ workshop: Workshops) throws {
        guard workshop.endTime > Date() else {
            throw ReservationsError.finished
        }
    }

    // Refuse une deuxième réservation non annulée du même utilisateur sur le même atelier (409).
    private func ensureNoActiveReservation(userID: UUID, workshopID: UUID, on db: any Database) async throws {
        let existingReservation = try await Reservations.query(on: db)
            .filter(\.$user.$id == userID)
            .filter(\.$workshop.$id == workshopID)
            .filter(\.$status != .cancelled)
            .first()

        guard existingReservation == nil else {
            throw ReservationsError.activeReservation
        }
    }

    // Gestion de la variation du nombre de place d'un worskshop pour les réservations en pending
    private func promoteWaitingReservations(for workshop: Workshops, on db: any Database) async throws {
        let workshopID = try workshop.requireID()
        while workshop.subscriberNumber < workshop.capacityMax {
            guard let next = try await Reservations.query(on: db)
                .filter(\.$workshop.$id == workshopID)
                .filter(\.$status == .pending)
                .sort(\.$id, .ascending)
                .first() else {
                break
            }

            next.status = .validated
            try await next.update(on: db)
            workshop.subscriberNumber += 1
            try await workshop.update(on: db)
        }
    }
}
