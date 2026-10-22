//
//  UpdateUserDTO.swift
//  LineUpTest
//
//  Created by apprenant144 on 14/10/2026.
//

import Vapor
import Fluent

struct UpdateUsersDTO : Content {
    let name : String?
    let email : String?
    let password : String?
}
