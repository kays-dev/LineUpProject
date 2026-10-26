//
//  StaffMiddleware.swift
//  LineUpAPI
//
//  Created by Apprenant174 on 26/10/2026.
//

import Vapor

// Middleware/StaffMiddleware.swift
// Bloque l'accès aux rôles autres que UserRole.staff
final class StaffMiddleware: AsyncMiddleware {

    func respond (to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        
        // Récupère le payload de la requête après l'authentification
        let payload = try request.auth.require(UsersPayload.self)
        
        // Vérifie que le role contenu dans le payload est UserRole.staff
        guard payload.role ==  .staff else {
            throw Abort(.forbidden, reason: "Accès interdit.")
        }

        // Passer à la prochaine étape du traitement de la requête
        return try await next.respond(to: request)
    }
}
