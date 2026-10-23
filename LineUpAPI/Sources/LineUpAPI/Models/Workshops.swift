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
    var start_time: Date

    @Field(key: "end_time")
    var end_time: Date

    @Field(key: "capacity_max")
    var capacity_max: Int

    @Field(key: "subscriber_number")
    var subscriber_number: Int

    @Field(key: "description")
    var workshop_description: String

    @Parent(key: "category_id")
    var category: Categories
    
    @Children(for: \.$workshop)
    var reservations: [Reservations]


    
    init() {}

    init(
        id: UUID? = nil,
        name: String,
        start_time: Date,
        end_time: Date,
        capacity_max: Int,
        subscriber_number: Int,
        workshop_description: String,
    ) {
        self.id = id
        self.name = name
        self.start_time = start_time
        self.end_time = end_time
        self.capacity_max = capacity_max
        self.subscriber_number = subscriber_number
        self.workshop_description = workshop_description
    }

}

extension Workshops {
    
    func toDTO() throws -> WorkshopsResponseDTO {

        WorkshopsResponseDTO(
            id: try requireID(),
            name: name,
            startTime: start_time,
            endTime: end_time,
            capacityMax: capacity_max,
            subscriberNumber: subscriber_number,
            workshopDescription: workshop_description,
            categoryID: try requireID(),
            categoryName: category.name,
            remainingPlaces: countRemainingPlaces()
        )
        
    }
    
    func countRemainingPlaces() -> Int {
         return capacity_max - subscriber_number
    }
    
}
