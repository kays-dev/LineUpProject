//
//  WorkshopDescriptionSection.swift.swift
//  LineUpApp
//
//  Created by Apprenant131 on 26/10/2026.
//

import Foundation

// tableau de collection [name: description]
struct WorkshopDescriptionSection: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let detail: String
}
