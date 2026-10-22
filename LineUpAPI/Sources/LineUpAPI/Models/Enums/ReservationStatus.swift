//
//  ReservationStatus.swift
//  LineUpAPI
//
//  Created by Apprenant131 on 15/10/2026.
//

enum ReservationStatus : String, Codable, Sendable {
    case validated
    case pending
    case cancelled
    
    var label : String {
        
        switch self {
        case .validated : "validated" // validé
        case .pending: "pending" // en attente
        case .cancelled: "cancelled" // annulé
        }
        
    }
}
