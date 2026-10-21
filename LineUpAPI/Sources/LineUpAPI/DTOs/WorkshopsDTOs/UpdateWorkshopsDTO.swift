//
//  UpdateWorkshopDTO.swift
//  LineUpAPI
//
//  Created by Apprenant131 on 14/10/2026.
//

import Vapor

struct UpdateWorkshopsDTO: Content {
    var name: String?
    var start_time: Date?
    var end_time: Date?
    var capacity_max: Int?
    var subscriber_number: Int?
    var workshop_description: String?
    var categoryID: UUID?
}
