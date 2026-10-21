//
//  WorkshopPlanningResponseDTO.swift
//  LineUpAPI
//
//  Created by Apprenant131 on 14/10/2026.
//

import Vapor

struct WorkshopsPlanningResponseDTO: Content {
    var id: UUID
    var name: String
    var start_time: Date
    var end_time: Date
    var capacity_max: Int
    var subscriber_number: Int

    // récupéré depuis la table category
    var category_name: String
}
