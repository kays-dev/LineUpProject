//
//  CategoryResponseDTO.swift
//  LineUpTest
//
//  Created by Apprenant174 on 14/10/2026.
//

import Vapor
import Fluent

struct CategoryResponseDTO: Content {

    var id: UUID
    var name: String

}

extension Categories {

    func toDTO() throws -> CategoryResponseDTO {

        return CategoryResponseDTO(
            id: try requireID(),
            name: name
        )

    }
    
}
