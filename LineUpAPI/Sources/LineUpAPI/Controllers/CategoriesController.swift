//
//  CategoriesController.swift
//  LineUpTest
//
//  Created by Apprenant174 on 14/10/2026.
//

import Fluent
import Vapor

struct CategoriesController: RouteCollection {
    
    func boot(routes: any RoutesBuilder) throws {
        
        let categories = routes.grouped("categories")
        
        //GET /categories
        categories.get(use: index)
        
        //GET /categories/:id
        categories.get(":id", use: show)
        
        let backoffice = routes.grouped("backoffice", "categories")
        
        //POST backoffice/categories
        backoffice.post(use: create)
        
        backoffice.group(":id"){ category in
                
            //PUT backoffice/categories/:id
            category.put(use: update)
                
            //DELETE backoffice/categories/:id
            category.delete(use: delete)
        }
        
    }
    
    func index(req: Request) async throws  -> [CategoriesResponseDTO] {
        
        let categories = try await Categories.query(on: req.db)
            .sort(\.$name, .ascending)
            .all()
        
        return try categories.map{ try $0.toDTO() }
        
    }
    
    func create(req: Request) async throws -> CategoriesResponseDTO {
        
        let data = try req.content.decode(CreateCategoriesDTO.self)
        
        let category = data.toModel()
        
        category.name = try await checkValidName(for: category.name, on: req.db)
        
        try await category.create(on: req.db)
        
        return try category.toDTO()
    }
    
    func show(req: Request) async throws -> CategoriesResponseDTO {
        
        let category = try await fetchCategory(req)
        
        return try category.toDTO()
        
    }
    
    func update(req: Request) async throws -> CategoriesResponseDTO {
        
        let data = try req.content.decode(UpdateCategoriesDTO.self)
        
        let category = try await fetchCategory(req)
        
        category.name = try await checkValidName(for: data.name, excluding: category.id, on: req.db)
        
        try await category.update(on: req.db)
        
        return try category.toDTO()
        
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        
        let category = try await fetchCategory(req)
        
        try await checkChildren(of: category, on: req.db)
        
        try await category.delete(on: req.db)
        
        return .noContent
        
    }
    
}

extension CategoriesController {
    
    //Récupérer la category avec un :id
    private func fetchCategory(_ req: Request) async throws -> Categories {
        
        guard let id = req.parameters.get("id", as: UUID.self) else {
            
            throw Abort(.badRequest, reason: "Invalid parameter.")
            
        }
        
        guard let fetched = try await Categories.find(id , on: req.db)  else {
            
            throw Abort(.notFound, reason: "Category not found.")
            
        }
        
        return fetched
        
    }
    
    //Vérifier la validité d'un \.$name à envoyer
    private func checkValidName(for name: String, excluding id: UUID? = nil, on db: any Database) async throws -> String {
        
        //Vérifier si que le \.$name n'est pas vide
        let cleanName = name.split(whereSeparator: \.isWhitespace).joined(separator: " ")
        guard !cleanName.isEmpty else {
        
            throw Abort(.badRequest, reason: "Name must not be empty")
        }
        
        //Vérifier si que le \.$name est unique
        let sameName = Categories.query(on: db)
            .filter( Categories.self, \.$name == cleanName)
        
        if let id {
            
            sameName.filter(\.$id != id)
            
        }
        
        guard try await sameName.count() == 0  else {
            
            throw Abort(.conflict, reason: "Name must be unique")
            
        }
        
        return cleanName
    }
    
    //Vérifier qu'une category est sans \.$workshops
    private func checkChildren(of category: Categories, on db: any Database) async throws {
        
        let workshops = category.$workshops.query(on: db)
        
        guard try await workshops.count() == 0 else {
            
            throw Abort(.conflict, reason: "Category is linked to some workshops")
            
        }
        
    }
    
}
