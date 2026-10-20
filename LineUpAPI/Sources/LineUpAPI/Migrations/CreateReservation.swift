import Fluent

struct CreateReservation: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Reservation.schema)
            .id()
            .field("status", .string, .required)
            .field(
                "id_user", .uuid, .required,
                .references(User.schema, "id")
            )
            .field(
                "id_workshop", .uuid, .required,
                .references(Workshop.schema, "id")
            )
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Reservation.schema).delete()
    }
}
