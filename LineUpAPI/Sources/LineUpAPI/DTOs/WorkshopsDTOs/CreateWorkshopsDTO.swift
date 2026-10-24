//
//  CreateWorkshopDTO.swift
//  LineUpAPI
//
//  Created by Apprenant131 on 14/10/2026.
//

import Vapor
import Fluent

struct CreateWorkshopsDTO: Content {
    var name: String
    var startTime: Date
    var endTime: Date
    var capacityMax: Int
    var subscriberNumber: Int
    var workshopDescription: String
    var categoryID: UUID

    func toModel() -> Workshops {
        let workshop = Workshops(
            name: name,
            startTime: startTime,
            endTime: endTime,
            capacityMax: capacityMax,
            subscriberNumber: 0,
            workshopDescription: workshopDescription
        )
        workshop.$category.id = categoryID
        return workshop
    }
}
