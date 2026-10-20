//
//  CreateWorkshopDTO.swift
//  LineUpAPI
//
//  Created by Apprenant131 on 14/10/2026.
//

import Vapor

struct CreateWorkshopDTO: Content {
    var name: String
    var start_time: Date
    var end_time: Date
    var capacity_max: Int
    var workshop_description: String
    var categoryID: UUID

    func toModel() -> Workshops {
    let workshop = Workshops(
        name: name,
        start_time: start_time,
        end_time: end_time,
        capacity_max: capacity_max,
        subscriber_number: 0,
        workshop_description: workshop_description,
        categoryID: categoryID
    )
    return workshop
    }
}
