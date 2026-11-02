//
//  UsersPayload.swift
//  TestLineUp
//
//  Created by apprenant144 on 23/10/2026.
//

import Foundation
import Vapor
import JWT

struct UsersPayload: JWTPayload, Authenticatable {
    var id: UUID
    var role : UserRole
    var expiration: Date
    
// Vérification de la validité du token
    func verify(using signer: JWTSigner) throws {
        if self.expiration < Date() {
            throw JWTError.invalidJWK // Lancer une erreur si le token est expiré
        }
    }
        // Initialisateur qui définit l'ID et la date d'expiration
    init (id: UUID, role: UserRole) {
            self.id = id
            self.role = role
            self.expiration = Date().addingTimeInterval(3600 * 72)
        }
    }
