//
//  ReservationStatus.swift
//  LineUpAPI
//
//  Created by Apprenant131 on 15/10/2026.
//

enum ReservationStatus : Int, Codable {
    case approved = 0
    case pending = 1
    case cancelled = 2
    
    var label : String {
        
        switch self {
        case .approved : "approved" // approuvé
        case .pending: "pending" // en attente
        case .cancelled: "cancelled" // annulé
        }
        
    }
}
