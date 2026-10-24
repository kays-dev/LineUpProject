//
//  UserMigration.swift
//  LineUpTest
//
//  Created by apprenant144 on 14/10/2026.
//

import Fluent

struct CreateUsers: AsyncMigration {

    func prepare(on database: any Database) async throws {

        try await database.schema(Users.schema)
            .id()
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("password_hash", .string, .required)
            .field("role", .string, .required)
            .field("created_at", .datetime, .required)
            .unique (on: "email")
            .create()

    }

    func revert(on database: any Database) async throws {

        try await database.schema(Users.schema).delete()

    }

}
