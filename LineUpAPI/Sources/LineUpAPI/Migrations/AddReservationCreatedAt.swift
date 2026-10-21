import Fluent

struct AddReservationCreatedAt: AsyncMigration {
    func prepare(on database: any Database) async throws {
        // Le modèle n'a pas de champ created_at : c'est la base qui remplit la date.
        try await database.schema(Reservations.schema)
            .field("created_at", .custom("DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6)"), .required)
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Reservations.schema)
            .deleteField("created_at")
            .update()
    }
}
