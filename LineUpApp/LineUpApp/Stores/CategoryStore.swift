//
//  CategoryStore.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class CategoryStore {
    
    private(set) var categories: [Category] = []
    private let service: CategoryService
    
    init(service: CategoryService) {
        self.service = service
    }
    
    func fetchAll() async throws {
        
        categories = try await service.fetchAll()
        
    }
    
}
