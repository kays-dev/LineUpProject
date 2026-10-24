//
//  WorkshopController.swift
//  LineUpAPI
//
//  Created by Apprenant131 on 15/10/2026.
//

import Fluent
import Vapor

struct WorkshopsController: RouteCollection {
    
    func boot(routes: any RoutesBuilder) throws {
        
        let workshops = routes.grouped("workshops")
        
        // Liste de tous les workshops filtré (catégories - recherche - disponiblité - date)
        workshops.get(use: index)
        
        // Détail d'un atelier par son ID
        workshops.get(":id", use: showWorkshopsDetail)
        
        // Création
        workshops.post(use: create)
        
        // Modification et suppression
        workshops.group(":id") { workshop in
            workshop.put(use: update)
            workshop.delete(use: delete)
        }
        
    }
    
    // Liste de tous les workshops filtré (catégories - recherche - disponiblité - date)
    func index(req: Request) async throws -> [WorkshopsResponseDTO] {
        
        
        let query = Workshops.query(on: req.db)
            .with(\.$category)
        
        
        let categories = Categories
            .query(on: req.db)
        
        // Filtre / catégories
        if let selectedCategory = try req.query.get(String?.self, at: "category") {
            
            guard let cat = try await categories
                .filter(Categories.self, \.$name ~~ (selectedCategory)).first()
                    else {
                throw Abort(.notFound, reason: "Catégorie introuvable.")
            }
            
            query.filter(\.$category.$id == cat.id!)
        }
        
        // Filtre / recherche
        if let selectedName = try req.query.get(String?.self, at: "name") {
            query
                .filter(\.$name ~~ selectedName)
        }
        
        // Filtre / disponibilité
        if let status = req.query[String.self, at: "status"] {
            switch status {
            case "available":
                query.filter(\.$subscriberNumber, .lessThan, \.$capacityMax)
            case "full":
                query.filter(\.$subscriberNumber, .greaterThanOrEqual, \.$capacityMax)
            case "unavailable":
                query
                    .filter(\.$subscriberNumber == 0)
                    .filter(\.$capacityMax == 0)
            default:
                throw Abort(.badRequest, reason: "La statut de l'atelier doit être disponible ou complet.")
            }
        }
        
        // Filtre / date
        if let selectedDay = try req.query.get(String?.self, at: "period") {
            let (start, end) = try dayRange(for: selectedDay)
            query.filter(\.$startTime >= start).filter(\.$startTime < end)
        }
        
        return try await query
            .sort(\.$startTime, .ascending)
            .all().map {
                try $0.toDTO()
            }
    }
    
    // Detail des activités
    func showWorkshopsDetail(req: Request) async throws
    -> WorkshopsResponseDTO {
        
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "L'ID de l'atelier est invalide.")
        }
        
        guard let workshop = try await Workshops.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "L'atelier est introuvable.")
        }
        
        let dto = try workshop.toDTO()
        
        return dto
        
    }
    
    // Création
    func create(req: Request) async throws -> WorkshopsResponseDTO {
        let dto = try req.content.decode(CreateWorkshopsDTO.self)
        let workshop = dto.toModel()
        try await workshop.create(on: req.db)
        return try workshop.toDTO()
    }
    
    
    // Modifier un workshop
    func update(req: Request) async throws -> WorkshopsResponseDTO {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "L'ID de l'atelier est invalide.")
        }
        
        guard let workshop = try await Workshops.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "L'atelier est introuvable.")
        }
        
        let dto = try req.content.decode(UpdateWorkshopsDTO.self)
        
        // Mémoriser l'ancienne capacité
        let oldCapacityMax = workshop.capacityMax
        
        if let name = dto.name {
            workshop.name = name
        }
        
        if let startTime = dto.startTime {
            workshop.startTime = startTime
        }
        
        if let endTime = dto.endTime {
            workshop.endTime = endTime
        }
        
        if let capacityMax = dto.capacityMax {
            workshop.capacityMax = capacityMax
        }
        
        if let description = dto.workshopDescription {
            workshop.workshopDescription = description
        }
        
        try await workshop.update(on: req.db)
        
        // Si la capacité augmente, promouvoir les réservations en attente
        if workshop.capacityMax > oldCapacityMax {
            try await ReservationsController.promoteAfterCapacityIncrease(
                for: workshop,
                on: req.db
            )
        }
        
        return try workshop.toDTO()
    }
    
    // Suppression par ID
    func delete(req: Request) async throws -> HTTPStatus {
        
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "L'ID de l'atelier est invalide.")
        }
        
        guard let workshop = try await Workshops.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "L'atelier est introuvable.")
        }
        
        try await checkChildren(of: workshop, on: req.db)
        
        try await workshop.delete(on: req.db)
        
        return .noContent
    }
}


// Gestion du filtre date + suppression d'un Workshop avec des réservations
extension WorkshopsController {
    
    func showFestivalDays(req: Request) async throws -> [String] {
        let workshops = try await Workshops.query(on: req.db).all()
        let days = Set(workshops.map { formatDay().string(from: $0.startTime) })
        return days.sorted()
    }
    
    private func formatDay() -> DateFormatter {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Paris")!
        
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    private func dayRange(for day: String) throws -> (start: Date, end: Date) {
        let formatter = formatDay()
        guard let start = formatter.date(from: day),
              let end = formatter.calendar.date(byAdding: .day, value: 1, to: start) else {
            throw Abort(.badRequest, reason: "Date must be in yyyy-MM-dd format")
        }
        return (start, end)
    }
    
    private func checkChildren(of workshop: Workshops, on db: any Database) async throws {
        
        let reservations = workshop.$reservations.query(on: db)
        
        guard try await reservations.count() == 0 else {
            
            throw Abort(.conflict, reason: "Workshop is linked to some reservations")
            
        }
        
    }
}

