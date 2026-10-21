//
//  CreateUserDTO.swift
//  LineUpTest
//
//  Created by apprenant144 on 14/10/2026.
//

import Vapor
import Fluent

struct CreateUserDTO: Content {
    var name: String
    var email: String
    var password: String
    var created_at: Date?
    var role: UserRole?

    func toModel(
        passwordHash: String
    ) -> Users {
        let user = Users()
        user.name = name
        user.email = email
        user.password_hash = passwordHash
        user.created_at = created_at
        user.role = self.role ?? .festivalgoer
        
        return user
    }
 }
