//
//  ReservationStatus.swift
//  LineUpApp
//
//  Created by Apprenant174 on 26/10/2026.
//

import Foundation

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
