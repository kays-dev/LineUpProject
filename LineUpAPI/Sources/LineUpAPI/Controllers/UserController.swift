//
//  UserController.swift
//  LineUpTest
//
//  Created by apprenant144 on 14/10/2026.
//

import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        
        users.get(use: index) //
        users.post(use: create) //
        
        users.get("search",use: search) //
        users.get("sorted",use: sorted) //
        users.get("count",use: count) //
        users.get("role", use: filterByRole)
        
        users.group(":id") {user in
            user.get(use: show) //
            user.put(use: update) //
            user.delete(use: delete) //
        }
    }
    
    // Fonction qui affiche tous les users
    func index(req: Request) async throws -> [UserResponseDTO] {
        let user = try await User .query(on: req.db)
            .all()
        return try user.map { try $0.toDTO() }
    }
    
    // Fonction qui affiche un user
    func show(req: Request) async throws -> UserResponseDTO {
        guard let id = req.parameters.get(
            "id",
            as: UUID.self
        ) else {
            throw Abort(
                .badRequest,
                reason: "The provided ID is not valid."
            )
        }
        guard let user = try await User.find(
            id,
            on: req.db
        ) else {
            throw Abort(
                .notFound,
                reason: "No user matches this ID"
            )
        }
        return try user.toDTO()
    }
    
    // Fonction qui cree un user
    func create (req: Request) async throws -> UserResponseDTO {
        let dto = try req.content.decode (CreateUserDTO.self)
        let passwordHash = try await req.password.async.hash(dto.password)
        
        let user = dto.toModel(passwordHash: passwordHash)
        try await user.create( on: req.db)
        return try user.toDTO()
    }
    
    // Fonctions qui met a jour un user
    func update (req: Request) async throws -> UserResponseDTO {
        
        guard let id = req.parameters.get("id", as: UUID.self)
                else { throw Abort (.badRequest)}
        
        guard let user = try await User.find(id, on: req.db)
                else { throw Abort(.notFound)}
        
        let data = try req.content.decode(UpdateUserDTO.self)
        
        if let name = data.name {
            user.name = name
        }
        if let email = data.email {
            user.email = email
        }
        
        try await user.update(on: req.db)
        return try user.toDTO()
    }
    
    // Fonction qui supprime un user
    func delete (req: Request ) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as:UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let user = try await User.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        try await user.delete(on: req.db)
        return .noContent
    }
    
    // user.get("search",use: search)
    func search (req: Request) async throws -> [UserResponseDTO] {
        guard let name: String = req.query["name"] else {
            throw Abort(
                .badRequest,
                reason: "Name parameters is required"
            )
        }
        let users = try await User
            .query(on: req.db)
            .filter(\.$name ~~ name)
            .all()
        return try users.map {try $0.toDTO()}
    }
    
    // user.get("sorted",use: sorted)
    func sorted(req: Request) async throws -> [UserResponseDTO] {
        let query = User.query(on: req.db)
        let order: String? = req.query["order"]
        
        if order == "desc" {
            query.sort(
                \.$name,
                 .descending
            )
        } else {
            query.sort(
                \.$name,
                 .ascending
            )
        }
        let users = try await query.all()
        return try users.map {try $0.toDTO()}
    }
    
    // user.get("count",use: count)
    func count (req: Request) async throws -> Int {
        return try await User
            .query(on: req.db)
            .count()
    }
    
    // users.get("role", use: filterByRole)
    func filterByRole (req: Request) async throws -> [UserResponseDTO] {
        guard let roleString: String = req.query["role"],
        let role = UserRole(rawValue: roleString) else {
            throw Abort (
                .badRequest,
                reason: "Role parameters is required and must be valid"
            )
        }
        let users = try await User
            .query(on: req.db)
            .filter(\.$role == role)
            .all()
        return try users.map {try $0.toDTO()}
    }
}

