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
        
        // Authentifaction (staff/festivalier)
        let workshops = routes.grouped("workshops").grouped(JWTMiddleware())
        
        // Liste de tous les workshops filtré
        workshops.get(use: index)
        //workshops.
        
        // Détail d'un atelier
        workshops.get(":id", use: showWorkshopsDetail)
        //workshops.
        
        // tableaux de dates pour le selecteur
        workshops.get("days", use: showFestivalDays)
        //workshops.
        
        // Authentification + role staff backoffice
        let backoffice = routes.grouped("backoffice", "workshops").grouped(JWTMiddleware(), StaffMiddleware())
        
        // Création
        backoffice.post(use: create)
        
        // Modification et suppression
        backoffice.group(":id") { workshop in
            workshop.patch(use: update)
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
                .filter(Categories.self, \.$name == (selectedCategory))
                .first()
                    else {
                throw WorkshopsError.noCategory
            }
            
            query.filter(\.$category.$id == cat.id!)
        }
        
        // Filtre / recherche
        if let selectedName = try req.query.get(String?.self, at: "name") {
            query.filter(\.$name ~~ selectedName)
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
                throw WorkshopsError.invalidStatus
            }
        }
        
        // Filtre / date
        if let periods = try req.query.get(String?.self, at: "periods") {
            
            // Découpe la chaîne en liste de dates
            let days = periods.split(separator: ",").map { day in
                String(day)
            }
            
            // calcule la plage (début, fin) de chaque jour
            let ranges = try days.map { day in
                try dayRange(for: day)
            }
            
            // garde les ateliers qui démarrent l'un des jours sélectionnés
            if !ranges.isEmpty {
                
                query.group(.or) { or in
                    
                    // (jour 1) OR (jour 2) OR ...
                    for (start, end) in ranges {
                        
                        // Dans un jour, les deux conditions doivent être vraies (AND)
                        or.group(.and) { and in
                            // à partir de 00:00 ce jour-là (inclus)
                            and.filter(\.$startTime >= start)
                            // avant 00:00 le lendemain (exclu)
                            and.filter(\.$startTime < end)
                        }
                    }
                }
            }
        }
        
        return try await query
            .sort(\.$startTime, .ascending)
            .all()
            .map {
                try $0.toDTO()
            }
        
    }
    
    // Detail des activités
    func showWorkshopsDetail(req: Request) async throws
    -> WorkshopsResponseDTO {
        
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw WorkshopsError.invalidID
        }
        
        guard let workshop = try await Workshops.query(on: req.db)
            .filter(\.$id == id)
            .with(\.$category)
            .first()
                else {
            throw WorkshopsError.noWorkshop
        }
        
        let dto = try workshop.toDTO()
        
        return dto
        
    }
    
    // Création
    func create(req: Request) async throws -> WorkshopsResponseDTO {
        let dto = try req.content.decode(CreateWorkshopsDTO.self)
        
        let workshop = dto.toModel()
        try await workshop.create(on: req.db)
        // .load == .with()
        try await workshop.$category.load(on: req.db)
        return try workshop.toDTO()
    }
    
    
    // Modification
    func update(req: Request) async throws -> WorkshopsResponseDTO {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw WorkshopsError.invalidID
        }
        
        guard let workshop = try await Workshops.query(on: req.db)
            .filter(\.$id == id)
            .with(\.$category)
            .first()
                else {
            throw WorkshopsError.noWorkshop
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
    
    // Suppression
    func delete(req: Request) async throws -> HTTPStatus {
        
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw WorkshopsError.invalidID
        }
        
        guard let workshop = try await Workshops.find(id, on: req.db) else {
            throw WorkshopsError.noWorkshop
        }
        
        try await checkChildren(of: workshop, on: req.db)
        
        try await workshop.delete(on: req.db)
        
        return .noContent
    }
}

// Gestion du filtre date + suppression d'un Workshop avec 0 réservation
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
            throw WorkshopsError.wrongDateFormat
        }
        return (start, end)
    }
    
    private func checkChildren(of workshop: Workshops, on db: any Database) async throws {
        
        let reservations = workshop.$reservations.query(on: db)
        
        guard try await reservations.count() == 0 else {
            throw WorkshopsError.hasReservations
        }
    }
}
