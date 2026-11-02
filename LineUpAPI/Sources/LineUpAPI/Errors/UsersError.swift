//
//  UsersError.swift
//  LineUpAPI
//
//  Created by Apprenant174 on 27/10/2026.
//

import Vapor

enum UsersError : Error {
    
    case invalidID
    case noUser
    case takenEmail
    case failedLogin
    case wrongPassword
    case samePassword
    
}

extension UsersError : AbortError {
    
    var status: HTTPResponseStatus {
        
        switch self {
            
        case .invalidID : .badRequest
        case .noUser : .notFound
        case .takenEmail : .conflict
        case .failedLogin : .unauthorized
        case .wrongPassword, .samePassword : .badRequest
            
        }
        
    }
    
    var reason: String {
        
        switch self {
            
        case .invalidID : "Identifiant invalide."
        case .noUser : "Utilisateur introuvable."
        case .takenEmail : "Cet email est déja utilisé par un autre compte."
        case .failedLogin : "L'utilisateur ou le mot de passe est incorrect."
        case .wrongPassword : "Le mot de passe actuel est incorrect."
        case .samePassword : "Le nouveau mot de passe doit être différent de l'ancien."
            
        }
        
    }
    
}
