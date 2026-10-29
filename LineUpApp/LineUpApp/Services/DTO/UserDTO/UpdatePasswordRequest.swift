//
//  UpdatePasswordRequest.swift
//  LineUpApp
//
//  Created by Apprenant174 on 29/10/2026.
//

import Foundation

struct UpdatePasswordRequest : Encodable {
    
    let name: String
    let email: String
    let password: String
    
}
