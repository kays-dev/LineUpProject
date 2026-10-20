import Fluent
import Vapor

struct ReservationController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let reservations = routes.grouped("reservations")
        reservations.post(use: create)
        reservations.get(use: myReservations)
        reservations.get("search", use: myReservations)
        reservations.get(":reservationID", use: show)
        reservations.patch(":reservationID", "cancel", use: cancel)

        let backOffice = routes.grouped("backoffice", "reservations")

        backOffice.get(use: index)
        backOffice.get("search", use: index)
        backOffice.get(":reservationID", use: show)
        backOffice.patch(":reservationID", "cancel", use: cancel)
        backOffice.patch(":reservationID", "status", use: updateStatus)
        backOffice.delete(":reservationID", use: delete)
        backOffice.patch("workshop", ":workshopID", "cancel", use: cancelForWorkshop)
        backOffice.delete("workshop", ":workshopID", use: deleteForWorkshop)
    }

    func create(req: Request) async throws -> ReservationResponseDTO {
        let dto = try req.content.decode(CreateReservationDTO.self)

        guard try await User.find(dto.userID, on: req.db) != nil else {
            throw Abort(.notFound, reason: "Utilisateur introuvable.")
        }
        guard let workshop = try await Workshop.find(dto.workshopID, on: req.db) else {
            throw Abort(.notFound, reason: "Atelier introuvable.")
        }

        let status: ReservationStatus
        if workshop.subscriber_number < workshop.capacity_max {
            status = .approved
        } else {
            status = .pending
        }

        let reservation = dto.toModel(status: status)

        try await reservation.create(on: req.db)

        if status == .approved {
            workshop.subscriber_number += 1
            try await workshop.update(on: req.db)
        }

        return try reservation.toDTO()
    }

    // Sélection par userID fourni dans l'URL, sans contrôle d'identité.
    func myReservations(req: Request) async throws -> [ReservationResponseDTO] {
        let filters = try req.query.decode(ReservationQueryDTO.self)

        guard let userID = filters.userID else {
            throw Abort(.badRequest, reason: "Le paramètre userID est obligatoire.")
        }

        let query = Reservation.query(on: req.db)
            .filter(\.$user.$id == userID)

        if let status = filters.status {
            query.filter(\.$status == status)
        }
        if let workshopID = filters.workshopID {
            query.filter(\.$workshop.$id == workshopID)
        }
        if let name = filters.name, !name.isEmpty {
            query
                .join(parent: \.$workshop)
                .filter(Workshop.self, \.$name ~~ name)
        }

        let reservations = try await query.sort(\.$id, .ascending).all()
        return try reservations.map { try $0.toDTO() }
    }

    // Consultation globale avec un filtre utilisateur facultatif.
    func index(req: Request) async throws -> [ReservationResponseDTO] {
        let filters = try req.query.decode(ReservationQueryDTO.self)
        let query = Reservation.query(on: req.db)

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
                .filter(Workshop.self, \.$name ~~ name)
        }

        let reservations = try await query.sort(\.$id, .ascending).all()
        return try reservations.map { try $0.toDTO() }
    }

    func show(req: Request) async throws -> ReservationResponseDTO {
        guard let reservationID = req.parameters.get("reservationID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Identifiant de réservation invalide.")
        }
        guard let reservation = try await Reservation.find(reservationID, on: req.db) else {
            throw Abort(.notFound, reason: "Réservation introuvable.")
        }

        return try reservation.toDTO()
    }

    // Une annulation conserve la réservation et son identifiant en base.
    func cancel(req: Request) async throws -> ReservationResponseDTO {
        guard let reservationID = req.parameters.get("reservationID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Identifiant de réservation invalide.")
        }
        guard let reservation = try await Reservation.find(reservationID, on: req.db) else {
            throw Abort(.notFound, reason: "Réservation introuvable.")
        }

        if reservation.status == .approved {
            let workshop = try await reservation.$workshop.get(on: req.db)
            workshop.subscriber_number -= 1
            try await workshop.update(on: req.db)
        }

        reservation.status = .cancelled
        try await reservation.update(on: req.db)

        return try reservation.toDTO()
    }

    func updateStatus(req: Request) async throws -> ReservationResponseDTO {
        guard let reservationID = req.parameters.get("reservationID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Identifiant de réservation invalide.")
        }
        guard let reservation = try await Reservation.find(reservationID, on: req.db) else {
            throw Abort(.notFound, reason: "Réservation introuvable.")
        }

        let dto = try req.content.decode(UpdateReservationDTO.self)

        if reservation.status != .approved && dto.status == .approved {
            let workshop = try await reservation.$workshop.get(on: req.db)
            workshop.subscriber_number += 1
            try await workshop.update(on: req.db)
        } else if reservation.status == .approved && dto.status != .approved {
            let workshop = try await reservation.$workshop.get(on: req.db)
            workshop.subscriber_number -= 1
            try await workshop.update(on: req.db)
        }

        reservation.status = dto.status
        try await reservation.update(on: req.db)

        return try reservation.toDTO()
    }

    // Suppression définitive d'une seule réservation via l'URL du back-office.
    func delete(req: Request) async throws -> HTTPStatus {
        guard let reservationID = req.parameters.get("reservationID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Identifiant de réservation invalide.")
        }
        guard let reservation = try await Reservation.find(reservationID, on: req.db) else {
            throw Abort(.notFound, reason: "Réservation introuvable.")
        }

        if reservation.status == .approved {
            let workshop = try await reservation.$workshop.get(on: req.db)
            workshop.subscriber_number -= 1
            try await workshop.update(on: req.db)
        }

        try await reservation.delete(on: req.db)
        return .noContent
    }

    func cancelForWorkshop(req: Request) async throws -> HTTPStatus {
        guard let workshopID = req.parameters.get("workshopID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Identifiant d'atelier invalide.")
        }
        guard let workshop = try await Workshop.find(workshopID, on: req.db) else {
            throw Abort(.notFound, reason: "Atelier introuvable.")
        }

        try await Reservation.query(on: req.db)
            .filter(\.$workshop.$id == workshopID)
            .set(\.$status, to: .cancelled)
            .update()

        workshop.subscriber_number = 0
        try await workshop.update(on: req.db)

        return .noContent
    }

    // Supprime les réservations de l'atelier, sans supprimer l'atelier lui-même.
    func deleteForWorkshop(req: Request) async throws -> HTTPStatus {
        guard let workshopID = req.parameters.get("workshopID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Identifiant d'atelier invalide.")
        }
        guard let workshop = try await Workshop.find(workshopID, on: req.db) else {
            throw Abort(.notFound, reason: "Atelier introuvable.")
        }

        try await Reservation.query(on: req.db)
            .filter(\.$workshop.$id == workshopID)
            .delete()

        workshop.subscriber_number = 0
        try await workshop.update(on: req.db)

        return .noContent
    }

}
