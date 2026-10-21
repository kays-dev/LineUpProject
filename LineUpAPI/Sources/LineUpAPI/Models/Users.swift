//
//  UserModel.swift
//  LineUpTest
//
//  Created by apprenant144 on 14/10/2026.
//

import Vapor
import Fluent

final class Users: Model, @unchecked Sendable {
    
    static let schema = "user"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var password_hash: String

    @Field(key: "role")
    var role: UserRole

    @Timestamp(key: "created_at", on: .create)
    var created_at: Date?

    @Children(for: \.$user)
    var reservations: [Reservations]

    init() { }

    init(id: UUID? = nil, name: String, email: String, password_hash: String, role: UserRole = .festivalgoer, created_at: Date? = nil) {

        self.id = id
        self.name = name
        self.email = email
        self.password_hash = password_hash
        self.role = role
        self.created_at = created_at

    }

 }
