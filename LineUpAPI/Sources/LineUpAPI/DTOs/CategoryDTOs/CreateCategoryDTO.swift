//
//  CreateCategoryDTO.swift
//  LineUpTest
//
//  Created by Apprenant174 on 14/10/2026.
//

import Vapor
import Fluent

struct CreateCategoryDTO: Content {

    var name: String

    func toModel() -> Categories {

        return Categories(
            name: name
        )

    }

}
