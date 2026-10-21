//
//  CategoryResponseDTO.swift
//  LineUpTest
//
//  Created by Apprenant174 on 14/10/2026.
//

import Vapor
import Fluent

struct CategoriesResponseDTO: Content {

    var id: UUID
    var name: String

}

extension Categories {

    func toDTO() throws -> CategoriesResponseDTO {

        return CategoriesResponseDTO(
            id: try requireID(),
            name: name
        )

    }
    
}
