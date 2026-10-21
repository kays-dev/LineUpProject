import Fluent
import FluentSQL
import Vapor

extension Reservations {
    // Une extension ne peut pas stocker de @Timestamp : ce champ existe uniquement en base.
    static var createdAtKey: FieldKey { "created_at" }

    // Remet la date à maintenant : la personne repasse en fin de file d'attente.
    // SQL brut (SQLKit) car le modèle n'a pas de propriété created_at.
    func renewCreatedAt(on db: any Database) async throws {
        guard let sql = db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Base SQL requise.")
        }
        try await sql.raw("UPDATE reservations SET created_at = CURRENT_TIMESTAMP(6) WHERE id = \(bind: requireID())").run()
    }

    // À appeler dans la transaction qui a modifié le compteur de l'atelier.
    static func promoteWaitingReservations(for workshop: Workshops, on db: any Database) async throws {
        let workshopID = try workshop.requireID()
        while workshop.subscriber_number < workshop.capacity_max {
            guard let next = try await Reservations.query(on: db)
                .filter(\.$workshop.$id == workshopID)
                .filter(\.$status == .pending)
                .sort(Self.createdAtKey, .ascending)
                .sort(\.$id, .ascending)
                .first() else {
                break
            }

            next.status = .approved
            try await next.update(on: db)
            workshop.subscriber_number += 1
            try await workshop.update(on: db)
        }
    }
}
