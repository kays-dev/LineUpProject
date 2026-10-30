//
//  UpdatePasswordDTO.swift
//  LineUpAPI
//
//  Created by apprenant144 on 30/10/2026.
//

import Vapor

struct UpdatePasswordDTO: Content, Validatable {
    let currentPassword: String
    let newPassword: String

    static func validations(_ validations: inout Validations) {
        validations.add("newPassword", as: String.self, is: .count(6...))
    }
}
