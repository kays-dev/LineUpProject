//
//  UserController.swift
//  LineUpTest
//
//  Created by apprenant144 on 14/10/2026.
//

import Fluent
import Vapor
import JWT

struct UsersController: RouteCollection {
    func boot (routes: any RoutesBuilder) throws {
        // Routes publiques
        let users = routes.grouped("users")
        // Inscription d'un festivalier depuis l'app
        users.post(use: create)
        
        // Route Protege par JWTMiddleware
        let protectedRoutes = users.grouped(JWTMiddleware())
        protectedRoutes.group(":id") {user in
            user.get(use: show)
            user.patch(use: update)
            user.delete(use: delete)
        }
        
        let backoffice = protectedRoutes.grouped("backoffice")
        //Création d'un utilisateur par le staff (depuis le dashboard JS)
        // Permet au staff de créer soit un autre membre du staff, soit d'inscrire un festivalier
        backoffice.post(use: create)
        
        // Consultation, recherche, tris et statistique pour le staff
        backoffice.get(use: index)
        backoffice.get("count", use: count)
        // Gestion avancée d'un utilisateur par un administrateur
        backoffice.group(":id") { user in
            user.get(use: show)
            user.patch(use: update)
            user.delete(use: delete)
        }
    }
    
    // Fonction qui gère index, search, filterByRole et sorted combinés
    func index(req: Request) async throws -> [UsersResponseDTO] {
        // Décodage des paramètres optionnels de l'URL (Query Parameters)
        let queryParams = try req.query.decode(UsersQueryDTO.self)
        
        let query = Users.query(on: req.db)
        
        // 1. Filtrage par nom (recherche partielle, insensible à la casse ou similaire)
        if let name = queryParams.name, !name.isEmpty {
            query.filter(\.$name ~~ name)
        }
        
        // 2. Filtrage par rôle
        if let role = queryParams.role {
            query.filter(\.$role == role)
        }
        
        // 3. Gestion du tri (Par défaut : nom croissant si non spécifié)
        let sortOrder: DatabaseQuery.Sort.Direction = (queryParams.order?.lowercased() == "desc") ? .descending : .ascending
        query.sort(\.$name, sortOrder)
        
        let users = try await query.all()
        return try users.map { try $0.toDTO() }
    }
    
    // Fonction qui affiche un user
    func show(req: Request) async throws -> UsersResponseDTO {
        guard let id = req.parameters.get(
            "id",
            as: UUID.self
        ) else {
            throw Abort(
                .badRequest,
                reason: "The provided ID is not valid."
            )
        }
        guard let user = try await Users.find(
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
    @Sendable
    func create (req: Request) async throws -> UsersResponseDTO {
        // Valide la requête selon les règles définies dans Validatable (lance un 400 si invalide)
        try CreateUsersDTO.validate(content: req)
        
        let dto = try req.content.decode (CreateUsersDTO.self)
        
        // Verifie si l'email existe deja -> erreur 409 Conflit
        let existingUser = try await Users.query(on: req.db)
            .filter(\.$email == dto.email)
            .first()
        if existingUser != nil {
            throw Abort(.conflict, reason: "Cet email est déja utilisé par un autre compte.")
        }
        
        // Hachage du mot de passe via BCrypt
        let passwordHash = try Bcrypt.hash(dto.password)
        
        let user = dto.toModel(passwordHash: passwordHash)
        try await user.save( on: req.db) // save gere create + update
        return try user.toDTO()
    }
    
    @Sendable
    func login(req: Request) async throws -> String {
        // Décoder les données utilisateur à partir de la requête
        let userData = try req.content.decode(LoginRequest.self)
        
        // Rechercher l'utilisateur par email
        guard let user = try await Users.query(on: req.db)
            . filter(\.$email == userData.email)
            .first() else {
            throw Abort(.unauthorized, reason: "L'utilisateur ou le mot de passe sont incorrects.")
        }
        
        // Vérification du mot de passe
        guard try Bcrypt.verify(userData.password, created: user.passwordHash) else {
            throw Abort (.unauthorized, reason: "L'utilisateur ou le mot de passe sont incorrects.")
        }
        
        // Génération du token JWT
        let payload = UsersPayload(id: user.id!, role: user.role)
        let signer = JWTSigner.hs256(key: "cle_secrete") // Clé secrète sécurisée
        let token = try signer.sign(payload) // Signer le payload pour générer le token
        return token // Retourner le token au client
    }
    
    @Sendable
    func profile(req: Request) async throws -> UsersResponseDTO {
        
        // Essaye d'extraire le payload JWT de la requête
        let payload = try req.auth.require(UsersPayload.self)
        
        // Recherche l'utilisateur dans la base de données en utilisant l'ID extrait du payload
        guard let user = try await Users.find(payload.id, on: req.db) else {
            throw Abort(.notFound)
        }
            // Convertit l'utilisateur en DTO
        return try user.toDTO()
        }
            
            // Fonctions qui met a jour un user
            func update (req: Request) async throws -> UsersResponseDTO {
                
                guard let id = req.parameters.get("id", as: UUID.self)
                        else { throw Abort (.badRequest)}
                
                guard let user = try await Users.find(id, on: req.db)
                        else { throw Abort(.notFound)}
                
                let data = try req.content.decode(UpdateUsersDTO.self)
                
                if let name = data.name {
                    user.name = name
                }
                if let email = data.email {
                    user.email = email
                }
                
                // Si l'email est modifié, on vérifie son unicité -> Erreur 409 Conflict
                if let newEmail = data.email, newEmail != user.email {
                    let emailExists = try await Users.query(on: req.db)
                        .filter(\.$email == newEmail)
                        .first()
                    
                    if emailExists != nil {
                        throw Abort(.conflict, reason: "Cet email est déjà utilisé par un autre compte.")
                    }
                    user.email = newEmail
                }
                
                try await user.update(on: req.db)
                return try user.toDTO()
            }
            
            // Fonction qui supprime un user
            func delete (req: Request ) async throws -> HTTPStatus {
                guard let id = req.parameters.get("id", as:UUID.self) else {
                    throw Abort(.badRequest)
                }
                guard let user = try await Users.find(id, on: req.db) else {
                    throw Abort(.notFound)
                }
                try await user.delete(on: req.db)
                return .noContent
            }
            
            // user.get("count",use: count)
            func count (req: Request) async throws -> Int {
                return try await Users
                    .query(on: req.db)
                    .count()
            }
        }
        
