//
//  UpdateWorkshopDescription.swift
//  LineUpAPI
//
//  Created by Apprenant131 on 30/10/2026.
//

import Fluent

struct UpdateWorkshopDescription: AsyncMigration {

    func prepare(on database: any Database) async throws {
        try await database.schema(Workshops.schema)
            .updateField("description", .custom("TEXT"))
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Workshops.schema)
            .updateField("description", .string)
            .update()
    }
    
}
