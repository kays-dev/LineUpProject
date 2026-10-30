//
//  WorkshopResponse.swift
//  LineUpApp
//
//  Created by Apprenant131 on 29/10/2026.
//

import Foundation

// représente les données telles qu’elles arrivent dans le JSON envoyé par le  backend Vapor.
struct WorkshopResponse : Decodable {
    let id: UUID
    let name: String
    let startTime: Date
    let endTime: Date
    let capacityMax : Int
    let subscriberNumber: Int
    let workshopDescription: String
    let categoryID: UUID
    let categoryName: String
    let remainingPlaces: Int
    
    func toModel() -> Workshop {
        let workshop = Workshop(
            id:id,
            name: name,
            startTime: startTime,
            endTime: endTime,
            capacityMax: capacityMax,
            subscriberNumber: subscriberNumber,
            workshopDescription: workshopDescription,
            categoryID: categoryID,
            categoryName: categoryName,
            remainingPlaces: remainingPlaces
        )
        return workshop
    }
}
