//
//  User.swift
//  LineUpApp
//
//  Created by Apprenant174 on 26/10/2026.
//

import Foundation

@Observable
class User : Identifiable {
    
    let name : String
    let email: String
    
    init(name: String, email: String) {
        
        self.name = name
        self.email = email
        
    }
    
}
