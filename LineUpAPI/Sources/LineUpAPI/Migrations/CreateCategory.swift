//
//  File.swift
//  LineUpTest
//
//  Created by Apprenant174 on 14/10/2026.
//

import Fluent
import Vapor

struct CreateCategory: AsyncMigration {

    func prepare(on database: any Database) async throws {

        try await database.schema(Category.schema)
            .id()
            .field("name", .string, .required)
            .create()

    }

    func revert(on database: any Database) async throws {

        try await database.schema("category").delete()

    }
}
