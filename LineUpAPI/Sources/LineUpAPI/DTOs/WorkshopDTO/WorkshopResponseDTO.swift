//
//  WorkshopResponseDTO.swift
//  LineUpAPI
//
//  Created by Apprenant131 on 16/10/2026.
//

import Vapor

struct WorkshopResponseDTO: Content {
    var id: UUID
    var name: String
    var start_time: Date
    var end_time: Date
    var capacity_max: Int
    var subscriber_number: Int
    var category_name: String
}
