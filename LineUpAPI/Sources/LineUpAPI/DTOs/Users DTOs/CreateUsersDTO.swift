//
//  CreateUserDTO.swift
//  LineUpTest
//
//  Created by apprenant144 on 14/10/2026.
//

import Vapor
import Fluent

struct CreateUsersDTO: Content, Validatable {
    var name: String
    var email: String
    var password: String
    var role: UserRole? // Optionnel: par defaut, ce sera un festivalier

// Initialiseur personnalisé pour intercepter et nettoyer l'e-mail au décodage JSON
    init(from decoder: any Decoder) throws {
        // Codingkey: enum en cache qui liste les propriété du DTO = name, email, password, role
        // Le container lie les donné du json en utilisant la codingkey = propriété dto
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
            
        // Stock l'email brut (entrée par l'utilisateur)
        let rawEmail = try container.decode(String.self, forKey: .email)
        // Nettoyage automatique : supprime les espaces au début/fin et met en minuscules
        self.email = rawEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            
        self.password = try container.decode(String.self, forKey: .password)
        
        // Décode le rôle s'il est présent dans le JSON, sinon reste nil
        self.role = try container.decodeIfPresent(UserRole.self, forKey: .role)
    }
    
// Validation via le protocole Validatable de Vapor
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("name", as: String.self, is: !.empty);
        validations.add("email", as: String.self,is: .email);
        validations.add("password", as: String.self, is: .count(6...))

    }
    
    func toModel(
        passwordHash: String
    ) -> Users {
        let user = Users()
        user.name = name
        user.email = email
        user.passwordHash = passwordHash
        user.role = role ?? .festivalgoer // festivalgoer par defaut sauf si staff est precisé
        
        return user
    }
 }
