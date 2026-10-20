//
//  ReservationStatus.swift
//  LineUpAPI
//
//  Created by Apprenant131 on 15/10/2026.
//

enum ReservationStatus : String, Codable, Sendable {
    case approved
    case pending
    case cancelled
    
    var label : String {
        
        switch self {
        case .approved : "approved" // approuvé
        case .pending: "pending" // en attente
        case .cancelled: "cancelled" // annulé
        }
        
    }
}
