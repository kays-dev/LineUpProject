//
//  Workshop.swift
//  LineUpApp
//
//  Created by Apprenant174 on 26/10/2026.
//

import Foundation

// représente un atelier dans l'application, avec ses propriétés et les informations nécessaires à son fonctionnement.
struct Workshop: Identifiable, Hashable, CustomStringConvertible{
    let id: UUID
    let name: String
    let startTime: Date
    let endTime: Date
    let capacityMax : Int
    let subscriberNumber: Int
    let workshopDescription: String
    let categoryID: UUID
    let categoryName: String
    let remainingPlaces : Int
    
    var availability: Availability {
        if subscriberNumber < capacityMax {
            return .available
        }
        if (subscriberNumber == 0) && (capacityMax == 0) {
            return .unavailable
        }
        return .full
    }
    
    // faciliter le débogage et vérifier les données récupérées depuis l'API
    var description: String {
        return " Nom : \(name) Description : \(workshopDescription)
    }
}
