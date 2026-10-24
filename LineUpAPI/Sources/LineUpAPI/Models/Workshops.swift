//
//  Workshop.swift
//  LineUpAPI
//
//  Created by Apprenant131 on 15/10/2026.
//

import Fluent
import Vapor

final class Workshops: Model, @unchecked Sendable {

    static let schema = "workshops"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "start_time")
    var startTime: Date

    @Field(key: "end_time")
    var endTime: Date

    @Field(key: "capacity_max")
    var capacityMax: Int

    @Field(key: "subscriber_number")
    var subscriberNumber: Int

    @Field(key: "description")
    var workshopDescription: String

    @Parent(key: "category_id")
    var category: Categories
    
    @Children(for: \.$workshop)
    var reservations: [Reservations]


    
    init() {}

    init(
        id: UUID? = nil,
        name: String,
        startTime: Date,
        endTime: Date,
        capacityMax: Int,
        subscriberNumber: Int,
        workshopDescription: String,
    ) {
        self.id = id
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.capacityMax = capacityMax
        self.subscriberNumber = subscriberNumber
        self.workshopDescription = workshopDescription
    }

}

extension Workshops {
    
    func toDTO() throws -> WorkshopsResponseDTO {

        WorkshopsResponseDTO(
            id: try requireID(),
            name: name,
            startTime: startTime,
            endTime: endTime,
            capacityMax: capacityMax,
            subscriberNumber: subscriberNumber,
            workshopDescription: workshopDescription,
            categoryID: try requireID(),
            categoryName: category.name,
            remainingPlaces: countRemainingPlaces()
        )
        
    }
    
    func countRemainingPlaces() -> Int {
         return capacityMax - subscriberNumber
    }
    
}
