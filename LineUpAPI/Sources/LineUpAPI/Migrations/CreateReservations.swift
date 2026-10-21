import Fluent

struct CreateReservations: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Reservations.schema)
            .id()
            .field("status", .string, .required)
            .field(
                "id_user", .uuid, .required,
                .references(Users.schema, "id")
            )
            .field(
                "id_workshop", .uuid, .required,
                .references(Workshops.schema, "id")
            )
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Reservations.schema).delete()
    }
}
