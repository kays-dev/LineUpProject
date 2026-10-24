//
//  File.swift
//  LineUpTest
//
//  Created by Apprenant174 on 14/10/2026.
//

import Fluent
import Vapor

final class Categories: Model, @unchecked Sendable {

    static let schema = "categories"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Children(for: \.$category)
    var workshops: [Workshops]

    init() { }

    init (id: UUID? = nil, name: String) {

        self.id = id
        self.name = name

    }

}
