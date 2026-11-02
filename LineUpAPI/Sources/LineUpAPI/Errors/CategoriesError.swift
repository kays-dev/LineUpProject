//
//  CategoriesError.swift
//  LineUpAPI
//
//  Created by Apprenant174 on 27/10/2026.
//

import Vapor

enum CategoriesError : Error {
    
    case invalidID
    case noCategory
    case emptyName
    case takenName
    case hasWorkshops
    
}

extension CategoriesError : AbortError {
    
    var status: HTTPResponseStatus {
        
        switch self {
            
        case .invalidID, .emptyName : .badRequest
        case .noCategory : .notFound
        case .takenName, .hasWorkshops : .conflict
            
        }
        
    }
    
    var reason: String {
        
        switch self {
            
        case .invalidID : "Identifiant de catégorie invalide."
        case .emptyName : "Le nom de la catégorie est obligatoire."
        case .noCategory : "Catégorie introuvable."
        case .takenName : "Une catégorie porte déjà ce nom."
        case .hasWorkshops : "Impossible de supprimer cette catégorie : un ou des ateliers y sont encore rattachés."
            
        }
        
    }
    
}
