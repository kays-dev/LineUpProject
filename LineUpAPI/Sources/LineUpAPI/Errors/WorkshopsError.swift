//
//  WorkshopsError.swift
//  LineUpAPI
//
//  Created by Apprenant174 on 27/10/2026.
//


import Vapor

enum WorkshopsError : Error {
    
    case noCategory
    case invalidStatus
    case invalidID
    case noWorkshop
    case wrongDateFormat
    case hasReservations
    
}

extension WorkshopsError : AbortError {
    
    var status: HTTPResponseStatus {
        
        switch self {
            
        case .invalidStatus, .invalidID, .wrongDateFormat : .badRequest
        case .noCategory, .noWorkshop : .notFound
        case .hasReservations : .conflict
            
        }
        
    }
    
    var reason: String {
        
        switch self {
            
        case .noCategory : "Catégorie introuvable."
        case .invalidStatus : "Statut de l'atelier invalide."
        case .invalidID : "L'ID de l'atelier est invalide."
        case .noWorkshop : "Atelier est introuvable."
        case .wrongDateFormat : "La date doit être au format aaaa-MM-jj."
        case .hasReservations : "Impossible de supprimer cet atelier : un ou des réservations y sont encore rattachées."
            
        }
        
    }
    
}
