//
//  UserQueryDTO.swift
//  LineUpAPI
//
//  Created by apprenant144 on 21/10/2026.
//

import Vapor

struct UsersQueryDTO: Content {
    var name: String?
    var role: UserRole?
    var order: String? // Alphabetique ASC ou DESC
}
