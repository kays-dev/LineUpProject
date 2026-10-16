//
//  WorkshopController.swift
//  LineUpAPI
//
//  Created by Apprenant131 on 15/10/2026.
//

import Fluent
import Vapor

struct WorkshopController: RouteCollection {

    func boot(routes: any RoutesBuilder) throws {

        let workshops = routes.grouped("workshop")

        // Liste de tous les workshops
        workshops.get(use: index)
        
        // Planning du festival
        workshops.get("planning", use: showWorkshopsPlanning)
        
        // Detail des activités
        workshops.get("detail", use: showWorkshopsDetail)
        
        // Filtrage par disponibilité
        workshops.get("available", use: showWorkshopsAvailable)
        
        // Filtrage par catégorie
        workshops.get("category", ":categoryID", "planning", use: showWorkshopsPlanningCategory)
        
        // Recherche par nom
        workshops.get("search", use: searchWorkshop)
        
        // Création
        workshops.post(use: create)
        
        // Modification et suppression par ID
        workshops.group(":id") { workshop in
            workshop.put(use: update)
            workshop.delete(use: delete)
        }
        
    }

    // Liste de tous les workshops
    func index(req: Request) async throws -> [Workshop] {
        return
            try await Workshop
            .query(on: req.db)
            .sort(\.$start_time, .descending)
            .all()
    }

    // Planning du festival
    func showWorkshopsPlanning(req: Request) async throws
        -> [WorkshopPlanningResponseDTO] {
        let workshops = try await Workshop.query(on: req.db)
            .with(\.$category)
            .sort(\.$start_time, .descending)
            .all()

        return try workshops.map { workshop in
            try workshop.toPlanningDTO(
                category_name: workshop.category.name
                )
            }
        }
    }

    // Planning du festival + Filtrage par catégorie
    func showWorkshopsPlanningCategory(req: Request) async throws
        -> [WorkshopPlanningResponseDTO] {
        guard let categorieID = req.parameters.get("categoryID", as: UUID.self) else {
            throw Abort(.notFound)
        }
        
        let workshops = try await Workshop.query(on: req.db)
            .filter(\.$category.$id == categorieID)
            .with(\.$category)
            .sort(\.$start_time, .ascending)
            .all()

        return try workshops.map { workshop in
            try workshop.toPlanningDTO(
                category_name: workshop.category.name
                )
        }
    }

    // Recherche par nom
    func searchWorkshop(req: Request) async throws -> [WorkshopResponseDTO] {
        guard let name: String = req.query["name"] else {
            throw Abort(.badRequest, reason: "Le paramètre name est obligatoire.")
        }

        let workshops = try await Workshop.query(on: req.db)
            .filter(\.$name ~~ name)
            .with(\.$category)
            .all()

        return try workshops.map { workshop in
            try workshop.toSearchDTO(category_name: workshop.category.name)
        }
    }


    // Planning du festival + Filtrage par disponibilité
    func showWorkshopsAvailable(req: Request) async throws -> [WorkshopPlanningResponseDTO] {
        
        let workshops = try await Workshop.query(on: req.db)
            .with(\.$category)
            .all()
        
        let workshopsAvailable =  workshops.filter { workshop in
            let placeRemaining = max(
                0,
                workshop.capacity_max
                -
                workshop.subscriber_number
            )
            return placeRemaining > 0
        
        }
        
        return try workshopsAvailable.map { workshop in
            try workshop.toPlanningDTO(
                category_name: workshop.category.name
                )
            }
    }

    // Detail des activités
    func showWorkshopsDetail(req: Request) async throws
        -> [WorkshopDetailResponseDTO] {
        let workshops = try await Workshop.query(on: req.db)
            .with(\.$category)
            .sort(\.$start_time, .descending)
            .all()

        return try workshops.map { workshop in
            let placeRemaining = max(
                0,
                workshop.capacity_max
                -
                workshop.subscriber_number
            )

            return try workshop.toDetailDTO(
                category_name: workshop.category.name,
                places_remaining: placeRemaining
            )
        }
    }

    // Création
    func create(req: Request) async throws -> Workshop {
        let dto = try req.content.decode(CreateWorkshopDTO.self)
        let workshop = dto.toModel()
        try await workshop.create(on: req.db)
        return workshop
    }

    // Modifier un workshop
    func update(req: Request) async throws -> Workshop {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.notFound)
        }

        guard let workshop = try await Workshop.find(id, on: req.db) else {
            throw Abort(.notFound)
        }

        let dto = try req.content.decode(UpdateWorkshopDTO.self)

        if let name = dto.name {
            workshop.name = name
        }

        if let startTime = dto.start_time {
            workshop.start_time = startTime
        }

        if let endTime = dto.end_time {
            workshop.end_time = endTime
        }

        if let capacityMax = dto.capacity_max {
            workshop.capacity_max = capacityMax
        }

        if let subscriberNumber = dto.subscriber_number {
            workshop.subscriber_number = subscriberNumber
        }

        if let description = dto.workshop_description {
            workshop.workshop_description = description
        }

        try await workshop.update(on: req.db)

        return workshop
    }

    // Suppression par ID
    func delete(req: Request) async throws -> HTTPStatus {
        let id = req.parameters.get("id", as: UUID.self)
        guard let workshop = try await Workshop.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        try await workshop.delete(on: req.db)
        return .noContent
    }
