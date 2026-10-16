//
//  File.swift
//  LineUpTest
//
//  Created by Apprenant174 on 14/10/2026.
//

import Fluent
import Vapor

final class Category: Model, Content, @unchecked Sendable {

    static let schema = "category"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Children(for: \.$category)
    var workshops: [Workshop]

    init() { }

    init (id: UUID? = nil, name: String) {

        self.id = id
        self.name = name

    }

}
