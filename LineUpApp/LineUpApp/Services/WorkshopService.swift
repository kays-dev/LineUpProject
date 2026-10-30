//
//  WorkshopService.swift
//  LineUpApp
//
//  Created by Apprenant174 on 26/10/2026.
//

import Foundation

struct WorkshopService {
    // propriété permettant l'utilisation de APIClient pour communiquer avec l'API
    private let apiClient: APIClient
    
    // initialiseur qui permet de transmettre une instance d'APIClient à WorkshopService
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    // récupérer la liste des ateliers filtré
    func fetchWorkshops(
        name: String? = nil,
        category: String? = nil,
        status: String? = nil,
        periods: [String]? = nil
    ) async throws -> [Workshop] {
        let dates = periods?.joined(separator: ",")
        let workshops: [WorkshopResponse] =
        try await apiClient.request(
            path: "workshops",
            query: [
                "name": name,
                "category": category,
                "status": status,
                "periods": dates
                ]
            )
        return workshops.map { workshopResponse in
            workshopResponse.toModel()
        }
    }
    
    // récupère un tableau de dates
    // absence de paramètres
    func fetchWorkshopsDays() async throws -> [String] {
        return try await apiClient.request(
            path: "workshops/days"
        )
    }
    
    // récupère le detail d'un atelier
    func fetchWorkshop(id: UUID) async throws -> Workshop {
        let workshop: WorkshopResponse = try await apiClient.request(
            path: "workshops/\(id)"
        )
        return workshop.toModel()
    }
}
