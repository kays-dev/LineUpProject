//
//  UserResponseDTO.swift
//  LineUpTest
//
//  Created by apprenant144 on 15/10/2026.
//


import Vapor
import Fluent

struct UsersResponseDTO: Content {
    var id: UUID
    var name: String
    var email: String
    var role: UserRole
   
}

extension Users {
    func toDTO() throws -> UsersResponseDTO {
        return UsersResponseDTO (
            id: try requireID(),
            name: name,
            email: email,
            role: role
        )
    }
}
