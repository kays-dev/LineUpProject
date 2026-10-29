import Testing
import VaporTesting
@testable import LineUpAPI

// R du CRUD : lire les catégories (GET)

extension LineUpAPITests {

    // Crée une catégorie par l'API (route staff) et renvoie la réponse décodée
    func createCategory(_ app: Application, name: String) async throws -> CategoriesResponseDTO {
        let token = try makeToken(role: .staff)
        let res = try await app.testing().sendRequest(.POST, "backoffice/categories", beforeRequest: { req in
            req.headers.add(name: .xForwardedFor, value: "127.0.0.1")
            req.headers.add(name: .authorization, value: "Bearer \(token)")
            try req.content.encode(CreateCategoriesDTO(name: name))
        })
        return try res.content.decode(CategoriesResponseDTO.self)
    }

    @Test("GET /categories renvoie les catégories triées par nom")
    func listCategoriesSortedByName() async throws {
        try await withApp { app in
            // Arrange : préparer
            _ = try await createCategory(app, name: "Théâtre")
            _ = try await createCategory(app, name: "Cinéma")
            let token = try makeToken(role: .festivalgoer)

            // Act : agir
            try await app.testing().test(.GET, "categories", beforeRequest: { req in
                req.headers.add(name: .xForwardedFor, value: "127.0.0.1")
                req.headers.add(name: .authorization, value: "Bearer \(token)")
            }, afterResponse: { res in
                // Assert : vérifier
                #expect(res.status == .ok)
                let categories = try res.content.decode([CategoriesResponseDTO].self)
                #expect(categories.map(\.name) == ["Cinéma", "Théâtre"])
            })
        }
    }
}
