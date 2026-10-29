//
//  Category.swift
//  LineUpApp
//
//  Created by Apprenant174 on 26/10/2026.
//

import Foundation

@Observable
class Category : Identifiable {
    
    let id : UUID
    let name : String
    
    init(id: UUID, name: String) {
        
        self.id = id
        self.name = name
        
    }
    
}
