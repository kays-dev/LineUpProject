//
//  Workshop.swift
//  LineUpAPI
//
//  Created by Apprenant131 on 15/10/2026.
//

import Fluent
import Vapor

final class Workshop: Model, Content, @unchecked Sendable {

    static let schema = "workshop"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "start_time")
    var start_time: Date  //type Date

    @Field(key: "end_time")
    var end_time: Date  //type Date

    @Field(key: "capacity_max")
    var capacity_max: Int

    @Field(key: "subscriber_number")
    var subscriber_number: Int

    @Field(key: "description")
    var workshop_description: String  //workshop_description pour éviter les interférences avec le CustomStringConvertible

    @Parent(key: "category_id")  //@Parent pas @Children
    var category: Category
    
    @Children(for: \.$workshop)  //@Children pas @Parent
    var reservations: [Reservation]

    
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

extension Workshop {

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

extension Workshop {
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

extension Workshop {
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
