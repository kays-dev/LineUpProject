//
//  JWTMiddleware.swift
//  TestLineUp
//
//  Created by apprenant144 on 23/10/2026.
//

import Vapor
import JWT

// Middleware/JWTMiddleware.swift
final class JWTMiddleware: Middleware {
    func respond (to request: Request, chainingTo next: any Responder) -> EventLoopFuture<Response> {
        
        // Vérifiez l'en-tête Authorization pour obtenir le token JWT
        guard let token = request.headers["Authorization"].first?.split(separator: " ").last else {
            return request.eventLoop.future(error: AccessError.failedAuth)
        }
        let signer = JWTSigner.hs256(key: "cle_secrete") // Remplacez par une clé secrète
        let payload: UsersPayload
        do {
            // Vérifiez le token et récupérez le payload
            payload = try signer.verify(String(token), as: UsersPayload.self)
        } catch {
            return request.eventLoop.future(error: AccessError.failedAuth)
        }
        // Attacher l'utilisateur au contexte de la requête
        request.auth.login(payload)
        
        // Passer à la prochaine étape du traitement de la requête
        return next.respond(to: request)
    }
}
