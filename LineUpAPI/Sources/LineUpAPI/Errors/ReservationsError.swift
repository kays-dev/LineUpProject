//
//  ReservationsError.swift
//  LineUpAPI
//
//  Created by Apprenant174 on 27/10/2026.
//

import Vapor

enum ReservationsError : Error {
    
    case noUser
    case emptyUserID
    case cannotCancelAgain
    case createToChange
    case cancelToChange
    case full
    case notNextInLine
    case noReservation
    case invalidWorkshopID
    case invalidID
    case noWorkshop
    case activeReservation
    case finished
    case staffAccount

}

extension ReservationsError : AbortError {
    
    var status: HTTPResponseStatus {
        
        switch self {
            
        case .emptyUserID, .invalidWorkshopID, .invalidID : .badRequest
        case .noUser, .noReservation, .noWorkshop : .notFound
        case .cannotCancelAgain, .createToChange, .cancelToChange, .full, .notNextInLine, .activeReservation, .finished, .staffAccount : .conflict
            
        }
        
    }
    
    var reason: String {
        
        switch self {
            
        case .noUser : "Utilisateur introuvable."
        case .emptyUserID : "Le paramètre userID est obligatoire."
        case .cannotCancelAgain : "La réservation est déjà annulée."
        case .createToChange : "La réservation est annulée. Créez une nouvelle réservation."
        case .cancelToChange : "Une réservation validée ne peut pas repasser en attente. Annulez-la plutôt."
        case .full : "L'atelier est complet."
        case .notNextInLine : "Une réservation plus ancienne est prioritaire."
        case .noReservation : "Réservation introuvable."
        case .invalidWorkshopID : "Identifiant d'atelier invalide."
        case .invalidID : "Identifiant de réservation invalide."
        case .noWorkshop : "Atelier introuvable."
        case .activeReservation : "Vous avez déjà une réservation active pour cet atelier."
        case .finished : "L'atelier est terminé."
        case .staffAccount : "Impossible de réserver pour un compte staff."
            
        }
        
    }
    
}
