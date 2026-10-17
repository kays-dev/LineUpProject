//
//  UserMigration.swift
//  LineUpTest
//
//  Created by apprenant144 on 14/10/2026.
//

import Fluent

struct CreateUser: AsyncMigration {

    func prepare(on database: any Database) async throws {

        try await database.schema("user")
            .id()
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("password_hash", .string, .required)
            .field("role", .string, .required)
            .field("created_at", .datetime, .required)
            .create()

    }

    func revert(on database: any Database) async throws {

        try await database.schema("user").delete()

    }

}
