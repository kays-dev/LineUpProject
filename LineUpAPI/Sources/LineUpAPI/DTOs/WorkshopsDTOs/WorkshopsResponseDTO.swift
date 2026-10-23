//
//  WorkshopResponseDTO.swift
//  LineUpAPI
//
//  Created by Apprenant131 on 16/10/2026.
//

import Vapor

struct WorkshopsResponseDTO: Content {
    
    var id: UUID
    var name: String
    var startTime: Date
    var endTime: Date
    var capacityMax: Int
    var subscriberNumber: Int
    var workshopDescription: String
    var categoryID: UUID
    var categoryName: String
    var remainingPlaces: Int

}
