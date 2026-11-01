//
//  Availability.swift
//  LineUpApp
//
//  Created by Apprenant174 on 26/10/2026.
//

import Foundation

enum Availability: CaseIterable, Hashable {
    case available
    case full
    
    var description: String {
        switch self {
        case .available:
            "Disponible"
        case .full:
            "Complet"
        }
    }
    
    var apiValue: String {
            switch self {
            case .available:
                "available"
            case .full:
                "full"
            }
        }
}
