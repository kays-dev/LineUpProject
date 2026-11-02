//
//  WorkshopStore.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

// Gère et conserve les ateliers

import Foundation
import Observation

@MainActor
@Observable
final class WorkshopStore {
    private let workshopService: WorkshopService
    
    init(workshopService: WorkshopService) {
        self.workshopService = workshopService
    }
    
    private(set) var workshops: [Workshop] = []
    private(set) var workshopDays: [String] = []
    private(set) var allCategories: [String] = []
    private(set) var isLoading = false
    
    func fetchWorkshops(
        periods: [String]? = nil,
        category: String? = nil,
        status: String? = nil
    ) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let result = try await workshopService.fetchWorkshops(
            periods: periods,
            category: category,
            status: status
        )
        // ignore un résultat devenu obsolète
        try Task.checkCancellation()
        workshops = result
        
        // Sans filtre actif, mémorisation de la liste complète des catégories
        if periods == nil && category == nil && status == nil {
            allCategories = Set(result.map(\.categoryName)).sorted()
        }
    }
    
    func fetchWorkshopsDays() async throws {
        workshopDays = try await workshopService.fetchWorkshopsDays()
    }
    
    func fetchWorkshops(
        name: String? = nil,
        periods: [String]? = nil,
        category: String? = nil,
        status: String? = nil
    ) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let result = try await workshopService.fetchWorkshops(
            name: name,
            periods: periods,
            category: category,
            status: status
        )
        try Task.checkCancellation()
        workshops = result
        
        // la liste complète des catégories ne se mémorise que sans aucun filtre
        if name == nil && periods == nil && category == nil && status == nil {
            allCategories = Set(result.map(\.categoryName)).sorted()
        }
    }
    
    func refreshWorkshop(id: UUID) async throws {
        let updated = try await workshopService.fetchWorkshop(id: id)
        if let index = workshops.firstIndex(where: { $0.id == id }) {
            workshops[index] = updated
        }
    }
}
