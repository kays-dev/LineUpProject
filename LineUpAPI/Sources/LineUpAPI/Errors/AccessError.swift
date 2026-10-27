//
//  AccessError.swift
//  LineUpAPI
//
//  Created by Apprenant174 on 27/10/2026.
//

import Vapor

enum AccessError : Error {
    
    case failedAuth
    case blockedAccess
    
}

extension AccessError : AbortError {
    
    var status: HTTPResponseStatus {
        
        switch self {
            
        case .failedAuth : .unauthorized
        case .blockedAccess : .forbidden
            
        }
        
    }
    
    var reason: String {
        
        switch self {
            
        case .failedAuth : "Token manquant."
        case .blockedAccess : "Accès refusé."
            
        }
        
    }
    
}
