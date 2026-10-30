//
//  Workshop.swift
//  LineUpApp
//
//  Created by Apprenant174 on 26/10/2026.
//

import Foundation

// représente un atelier dans l'application, avec ses propriétés et les informations nécessaires à son fonctionnement.
struct Workshop: Identifiable, Hashable, CustomStringConvertible{
    let id: UUID
    let name: String
    let startTime: Date
    let endTime: Date
    let capacityMax : Int
    let subscriberNumber: Int
    let workshopDescription: String
    let categoryID: UUID
    let categoryName: String
    let remainingPlaces : Int
    
    var availability: Availability {
        if subscriberNumber < capacityMax {
            return .available
        }
        return .full
    }
    
    // faciliter le débogage et vérifier les données récupérées depuis l'API
    var description: String {
        return " Nom : \(name) Description : \(workshopDescription) "
    }
}

extension Workshop {
    var descriptionSections: [WorkshopDescriptionSection] {
        let sections = workshopDescription
            .split(separator: "§")
            .compactMap { section -> WorkshopDescriptionSection? in

                // Transforme chaque section en objet WorkshopDescriptionSection
                let sectionComponents = section
                    .split(separator: "|")
                    .map {
                        // Convertit les Substring en String et supprime les espaces inutiles
                        String($0).trimmingCharacters(in: .whitespacesAndNewlines)
                    }

                guard sectionComponents.count == 2 else {
                    // Ignore la section si son format est incorrect
                    return nil
                }

                return WorkshopDescriptionSection(
                    name: sectionComponents[0],
                    detail: sectionComponents[1]
                )
            }

        return sections
    }
    
    // utilisation en swiftUI : workshop.descriptionSection(name: "Description")
    func descriptionSection(name: String) -> WorkshopDescriptionSection? {
        return descriptionSections.first { section in
            name == section.name
            }
    }

}
