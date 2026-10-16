//
//  WorkshopDetailResponseDTO.swift
//  LineUpAPI
//
//  Created by Apprenant131 on 14/10/2026.
//

import Vapor

struct WorkshopDetailResponseDTO: Content {
    var id: UUID
    var name: String
    var start_time: Date
    var end_time: Date
    var workshop_description: String
    
    // nbr de place restante
    var places_remaining: Int
    
    // nom de la categorie lié au workshop 
    var category_name: String
}
