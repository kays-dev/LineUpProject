//
//  UserResponse.swift
//  LineUpApp
//
//  Created by Apprenant174 on 29/10/2026.
//

import Foundation

struct UserResponse : Decodable {
    
    let id: UUID
    let name: String
    let email: String
    let role: UserRole
    
}
