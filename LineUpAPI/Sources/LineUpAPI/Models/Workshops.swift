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
        categoryID: UUID
    ) {
        self.id = id
        self.name = name
        self.start_time = start_time
        self.end_time = end_time
        self.capacity_max = capacity_max
        self.subscriber_number = subscriber_number
        self.workshop_description = workshop_description
        self.$category.id = categoryID
    }

}

extension Workshops {

    func toPlanningDTO(category_name: String) throws
        -> WorkshopPlanningResponseDTO{
        return WorkshopPlanningResponseDTO(
            id: try requireID(),
            name: name,
            start_time: start_time,
            end_time: end_time,
            capacity_max: capacity_max,
            subscriber_number: subscriber_number,
            category_name: category_name
        )
    }

}

extension Workshops {
    func toDetailDTO(category_name: String,places_remaining: Int) throws -> WorkshopDetailResponseDTO {
        return WorkshopDetailResponseDTO(
            id: try requireID(),
            name: name,
            start_time: start_time,
            end_time: end_time,
            workshop_description: workshop_description,
            places_remaining: places_remaining,
            category_name: category_name
        )
    }
}

extension Workshops {
    func toSearchDTO(category_name: String) throws -> WorkshopResponseDTO {
        return WorkshopResponseDTO(
            id: try requireID(),
            name: name,
            start_time: start_time,
            end_time: end_time,
            capacity_max: capacity_max,
            subscriber_number: subscriber_number,
            category_name: category_name
        )
    }
}
