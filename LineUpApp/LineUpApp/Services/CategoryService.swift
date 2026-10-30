//
//  CategoryService.swift
//  LineUpApp
//
//  Created by Apprenant174 on 30/10/2026.
//

import Foundation

final class CategoryService {
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func fetchAll() async throws -> [Category] {
        
        let response: [CategoriesResponse] = try await apiClient.request(path: "/categories")
        
        return response.map{ $0.toModel() }
        
    }
    
}
