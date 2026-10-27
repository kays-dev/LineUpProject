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
        
        // 1. Route d'authentification publique (/auth/login)
        let authRoutes = routes.grouped("auth")
        authRoutes.post("login", use: login)
        
        // 2. Routes de l'application iOS (/appios/users)
        let appiosUsers = routes.grouped("appios", "users")
        // Inscription d'un festivalier depuis l'app (POST /appios/users)
        appiosUsers.post(use: register)
        
        // Routes protégées par JWTMiddleware pour l'application iOS
        let protectedAppios = appiosUsers.grouped(JWTMiddleware())
        
        // Consulter son propre profil (GET /appios/users/me)
        protectedAppios.get("me", use: profile)
        
        // Gérer son compte via son ID (/appios/users/:id)
        protectedAppios.group(":id") { user in
            user.get(use: show)
            user.patch(use: update)
            user.delete(use: delete)
        }
        
        // 3. Routes du Backoffice réservées au Staff (/backoffice/users/...)
        let backofficeUsers = routes.grouped("backoffice", "users").grouped(JWTMiddleware(), StaffMiddleware())
        
        // Création d'un utilisateur staff (POST /backoffice/users)
        backofficeUsers.post(use: create)
        
        // Consultation, recherche, tris et statistiques pour le staff (GET /backoffice/users et /backoffice/users/count)
        backofficeUsers.get(use: index)
        backofficeUsers.get("count", use: count)
        
        // Gestion avancée d'un utilisateur par un administrateur (/backoffice/users/:id)
        backofficeUsers.group(":id") { user in
            user.get(use: show)
            user.patch(use: update)
            user.delete(use: delete)
        }
    }
    
    // Fonction qui permet de lister les utilisateurs avec des options de filtrage
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
    
    // Fonction permet de récupérer et d'afficher les détails complets d'un utilisateur spécifique à partir de son id passé dans l'URL
    func show(req: Request) async throws -> UsersResponseDTO {
        guard let id = req.parameters.get(
            "id",
            as: UUID.self
        ) else {
            throw UsersError.invalidID
        }
        
        try checkAccess(req: req, to: id)
        
        guard let user = try await Users.find(
            id,
            on: req.db
        ) else {
            throw UsersError.noUser
        }
        return try user.toDTO()
    }
    
    // Fonction qui crée un user
    @Sendable
    func createUser (req: Request, role: UserRole) async throws -> UsersResponseDTO {
        // Valide la requête selon les règles définies dans Validatable (lance un 400 si invalide)
        try CreateUsersDTO.validate(content: req)
        
        let dto = try req.content.decode (CreateUsersDTO.self)
        
        // Verifie si l'email existe deja -> erreur 409 Conflit
        let existingUser = try await Users.query(on: req.db)
            .filter(\.$email == dto.email)
            .first()
        if existingUser != nil {
            throw UsersError.takenEmail
        }
        
        // Hachage du mot de passe via BCrypt
        let passwordHash = try Bcrypt.hash(dto.password)
        
        let user = dto.toModel(passwordHash: passwordHash)
        user.role = role
        try await user.save( on: req.db) // save gere create + update
        return try user.toDTO()
    }
    
    // Route publique qui permet l'inscription d'un festivalgoer
    @Sendable
    func register(req: Request) async throws -> UsersResponseDTO {
        return try await createUser(req: req, role: .festivalgoer)
    }
    
    // Route backoffice qui permet l'inscription d'un staff
    @Sendable
    func create(req: Request) async throws -> UsersResponseDTO {
        return try await createUser(req:req, role: .staff)
    }
    
    // Controle l'acces au profil: compare l’id du token à celui de l’URL
    private func checkAccess(req: Request, to targetID: UUID) throws {
        let payload = try  req.auth.require(UsersPayload.self)
        // Autorisé si staff ou titulaire du compte
        guard payload.role == .staff || payload.id == targetID else {
            throw AccessError.blockedAccess
        }
    }
    
    // Route de login qui permet de s'authentifier
    @Sendable
    func login(req: Request) async throws -> String {
        // Décoder les données utilisateur à partir de la requête
        let userData = try req.content.decode(LoginRequest.self)
        
        // Rechercher l'utilisateur par email
        guard let user = try await Users.query(on: req.db)
            .filter(\.$email == userData.email)
            .first() else {
            throw UsersError.failedLogin
        }
        
        // Vérification du mot de passe
        guard try Bcrypt.verify(userData.password, created: user.passwordHash) else {
            throw UsersError.failedLogin
        }
        
        // Génération du token JWT
        let payload = UsersPayload(id: user.id!, role: user.role)
        let signer = JWTSigner.hs256(key: "cle_secrete") // Clé secrète sécurisée
        let token = try signer.sign(payload) // Signer le payload pour générer le token
        return token // Retourner le token au client
    }
    
    // Permet à un utilisateur authentifié de récupérer ses propres informations sans passer un ID dans l'URL
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
    
    // Fonctions qui de modifier les informations d'un user
    @Sendable
    func update (req: Request) async throws -> UsersResponseDTO {
        
        guard let id = req.parameters.get("id", as: UUID.self)
                else { throw Abort (.badRequest)}
        // Vérification des droits d'accès
        try checkAccess(req: req, to: id)
        
        // Valide la requête avec les règles de UpdateUsersDTO
        try UpdateUsersDTO.validate(content: req)
        let data = try req.content.decode(UpdateUsersDTO.self)
        
        guard let user = try await Users.find(id, on: req.db)
                else { throw Abort(.notFound)}
        
        if let name = data.name {
            user.name = name
        }
        
        // Si l'email est modifié, on vérifie son unicité -> Erreur 409 Conflict
        // Verifie que le champs est rempli.Si le champ est présent sa valeur est extraite et stockée temporairement dans la constante rawEmail, et le bloc de code s'exécute
        if let rawEmail = data.email {
            // Supprime espace et retour a la ligne, convertit le tout en minuscule
            let newEmail = rawEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            
            if newEmail != user.email {
                let emailExists = try await Users.query(on: req.db)
                    .filter(\.$email == newEmail)
                    .first()
                if emailExists != nil {
                    throw UsersError.takenEmail
                }
                user.email = newEmail
            }
        }
        
        // Gestion de la mise à jour du mot de passe
        if let password = data.password {
            user.passwordHash = try Bcrypt.hash(password)
        }
        
        try await user.update(on: req.db)
        return try user.toDTO()
    }
    
    // Fonction qui supprime un user
    func delete (req: Request ) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as:UUID.self) else {
            throw Abort(.badRequest)
        }
        
        try checkAccess(req: req, to: id)
        
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

