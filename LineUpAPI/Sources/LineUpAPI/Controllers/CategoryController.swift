//
//  CategoryController.swift
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
        
        //POST /categories
        categories.post(use: create)
        
        categories.group(":id"){ category in
            
            //GET /categories/:id
            category.get(use: show)
            
            //PUT /categories/:id
            category.put(use: update)
        }
        
    }
    
    private func fetchCategory(_ req: Request) async throws -> Categories {
        
        guard let id = req.parameters.get("id", as: UUID.self) else {
            
            throw Abort(.badRequest, reason: "Invalid parameter.")
            
        }
        
        guard let fetched = try await Categories.find(id , on: req.db)  else {
            
            throw Abort(.notFound, reason: "Category not found.")
            
        }
        
        return fetched
        
    }
    
    func index(req: Request) async throws  -> [CategoryResponseDTO] {
        
        let categories = try await Categories.query(on: req.db).all()
        
        return try categories.map{ try $0.toDTO() }
        
    }
    
    func create(req: Request) async throws -> CategoryResponseDTO {
        
        let dto = try req.content.decode(CreateCategoryDTO.self)
        
        let category = dto.toModel()
        
        try await category.create(on: req.db)
        
        return try category.toDTO()
        
    }
    
    func show(req: Request) async throws -> CategoryResponseDTO {
        
        let category = try await fetchCategory(req)
        
        return try category.toDTO()
        
    }
    
    func update(req: Request) async throws -> CategoryResponseDTO {
        
        let data = try req.content.decode(UpdateCategoryDTO.self)
        
        let category = try await fetchCategory(req)
        
        if let name = data.name {
            
            category.name = name
            
        }
        
        try await category.update(on: req.db)
        
        return try category.toDTO()
        
    }
    
}
