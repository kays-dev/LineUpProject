//
//  UpdateUserDTO.swift
//  LineUpTest
//
//  Created by apprenant144 on 14/10/2026.
//

import Vapor
import Fluent

struct UpdateUsersDTO : Content, Validatable{
    let name : String?
    let email : String?
    let password : String?
    
    static func validations(_ validations: inout Validations) {
        // Required false => valide la regle uniquement si le champs est rempli
        validations.add("name", as: String.self, is: !.empty, required: false)
        validations.add("email", as: String.self, is: .email, required: false)
        validations.add("password", as: String.self, is: .count(6...), required: false)
    }
}
