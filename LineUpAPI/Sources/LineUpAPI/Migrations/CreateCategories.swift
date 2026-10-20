//
//  File.swift
//  LineUpTest
//
//  Created by Apprenant174 on 14/10/2026.
//

import Fluent
import Vapor

struct CreateCategories: AsyncMigration {

    func prepare(on database: any Database) async throws {

        try await database.schema(Categories.schema)
            .id()
            .field("name", .string, .required)
            .create()

    }

    func revert(on database: any Database) async throws {

        try await database.schema(Categories.schema).delete()

    }
}
