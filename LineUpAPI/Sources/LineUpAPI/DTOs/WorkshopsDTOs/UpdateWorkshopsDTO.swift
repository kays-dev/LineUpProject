//
//  UpdateWorkshopDTO.swift
//  LineUpAPI
//
//  Created by Apprenant131 on 14/10/2026.
//

import Vapor

struct UpdateWorkshopsDTO: Content {
    var name: String?
    var startTime: Date?
    var endTime: Date?
    var capacityMax: Int?
    var workshopDescription: String?
    var categoryID: UUID?
}
