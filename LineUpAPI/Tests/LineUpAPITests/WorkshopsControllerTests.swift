import Foundation
import Testing
import VaporTesting
@testable import LineUpAPI

// U du CRUD : modifier un atelier (PATCH)

extension LineUpAPITests {

    // Crée un atelier de demain par l'API (route staff) et renvoie la réponse décodée
    func createWorkshop(_ app: Application, categoryID: UUID) async throws -> WorkshopsResponseDTO {
        let token = try makeToken(role: .staff)
        let startTime = Date().addingTimeInterval(3600 * 24)
        let input = CreateWorkshopsDTO(
            name: "Atelier masques",
            startTime: startTime,
            endTime: startTime.addingTimeInterval(3600 * 2),
            capacityMax: 10,
            subscriberNumber: 0,
            workshopDescription: "Fabrication de masques vénitiens.",
            categoryID: categoryID
        )
        let res = try await app.testing().sendRequest(.POST, "backoffice/workshops", beforeRequest: { req in
            req.headers.add(name: .xForwardedFor, value: "127.0.0.1")
            req.headers.add(name: .authorization, value: "Bearer \(token)")
            try req.content.encode(input)
        })
        return try res.content.decode(WorkshopsResponseDTO.self)
    }

    @Test("PATCH /backoffice/workshops/:id modifie seulement les champs envoyés")
    func updateWorkshop() async throws {
        try await withApp { app in
            // Arrange : préparer
            let category = try await createCategory(app, name: "Théâtre")
            let workshop = try await createWorkshop(app, categoryID: category.id)
            let token = try makeToken(role: .staff)
            let input = UpdateWorkshopsDTO(name: "Atelier masques et costumes", capacityMax: 20)

            // Act : agir
            try await app.testing().test(.PATCH, "backoffice/workshops/\(workshop.id)", beforeRequest: { req in
                req.headers.add(name: .xForwardedFor, value: "127.0.0.1")
                req.headers.add(name: .authorization, value: "Bearer \(token)")
                try req.content.encode(input)
            }, afterResponse: { res in
                // Assert : vérifier
                #expect(res.status == .ok)
                let updated = try res.content.decode(WorkshopsResponseDTO.self)
                #expect(updated.id == workshop.id)
                #expect(updated.name == "Atelier masques et costumes")
                #expect(updated.capacityMax == 20)
                #expect(updated.remainingPlaces == 20)
                #expect(updated.workshopDescription == workshop.workshopDescription)
            })
        }
    }
}
