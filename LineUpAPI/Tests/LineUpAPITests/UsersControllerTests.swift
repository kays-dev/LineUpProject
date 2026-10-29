import Foundation
import Testing
import VaporTesting
import JWT
@testable import LineUpAPI

// C du CRUD : créer un utilisateur (POST)
// Dans tous les tests, X-Forwarded-For donne une adresse client : sans elle, Gatekeeper répond 403

extension LineUpAPITests {

    // Fabrique un token comme la route login, avec la même clé que JWTMiddleware
    func makeToken(id: UUID = UUID(), role: UserRole) throws -> String {
        let payload = UsersPayload(id: id, role: role)
        return try JWTSigner.hs256(key: "cle_secrete").sign(payload)
    }

    // Inscrit un festivalier par l'API et renvoie la réponse décodée
    func createFestivalgoer(_ app: Application) async throws -> UsersResponseDTO {
        let input = ["name": "Marie Dupont", "email": "marie@example.com", "password": "secret123"]
        let res = try await app.testing().sendRequest(.POST, "appios/users", beforeRequest: { req in
            req.headers.add(name: .xForwardedFor, value: "127.0.0.1")
            try req.content.encode(input)
        })
        return try res.content.decode(UsersResponseDTO.self)
    }

    @Test("POST /appios/users inscrit un festivalier")
    func registerReturnsUser() async throws {
        try await withApp { app in
            // Arrange : préparer
            // CreateUsersDTO n'a pas d'init simple : on envoie le JSON sous forme de dictionnaire
            let input = ["name": "Marie Dupont", "email": "marie@example.com", "password": "secret123"]

            // Act : agir
            try await app.testing().test(.POST, "appios/users", beforeRequest: { req in
                req.headers.add(name: .xForwardedFor, value: "127.0.0.1")
                try req.content.encode(input)
            }, afterResponse: { res in
                // Assert : vérifier
                #expect(res.status == .ok)
                let user = try res.content.decode(UsersResponseDTO.self)
                #expect(user.name == "Marie Dupont")
                #expect(user.email == "marie@example.com")
                #expect(user.role == .festivalgoer)
            })
        }
    }
}
