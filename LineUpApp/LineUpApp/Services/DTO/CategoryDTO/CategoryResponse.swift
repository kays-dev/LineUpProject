//
//  CategoryResponse.swift
//  LineUpApp
//
//  Created by Apprenant174 on 29/10/2026.
//

import Foundation

struct CategoriesResponse: Decodable {

    let id: UUID
    let name: String

}

extension CategoriesResponse {
    
    func toModel() -> Category {
        
        return Category(id: id, name: name)
        
    }
    
}
