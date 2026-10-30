//
//  WorkshopStore.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

// Gère et conserve les ateliers

import Foundation

// type références
// Empêche l'héritage
final class WorkshopStore {
    // propriété permettant l'utilisation de WorkshopService
    private let workshopService: WorkshopService
    
    init(workshopService: WorkshopService) {
        self.workshopService = workshopService
    }
    
    // initialisation des ateliers et dates :
    // private(set) : Le Store peut lire et modifier les propriétés
    // Le ViewModel peut les lire
    // Le ViewModel ne peut pas les modifier directement
    private(set) var workshops: [Workshop] = []
    private(set) var workshopDays: [String] = []
    
    // récupère et stock les ateliers dans le store
    func fetchWorkshops() async throws {
        self.workshops = try await workshopService.fetchWorkshops()
    }
    
    // récupère et stock les dates dans le store
    func fetchWorkshopsDays() async throws {
        self.workshopDays = try await workshopService.fetchWorkshopsDays()
    }
}
