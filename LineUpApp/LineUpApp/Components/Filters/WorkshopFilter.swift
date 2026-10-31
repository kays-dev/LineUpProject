//
//  WorkshopFilter.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

struct WorkshopFilter: View {

    let dates: [String]
    let categories: [String]

    @State private var selectedDates: Set<String> = []
    @State private var selectedCategories: Set<String> = []
    @State private var selectedAvailabilities: Set<String> = []

    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading, spacing: AppToken.Spacing.s32) {
                
                HStack {
                    FilterHeader(
                        title: "Filtres",
                        icon: AppImage.Icon.filter.image,
                        font: AppFont.Title.heading.font
                    )
                    
                    // Button Back
                }
                
                FilterSection(
                    title: "Dates",
                    icon: AppImage.Icon.calendar.image,
                    items: dates,
                    selection: $selectedDates
                )
                
                FilterSection(
                    title: "Catégorie",
                    icon: AppImage.Icon.sparkles.image,
                    items: categories,
                    selection: $selectedCategories
                )
                
                FilterSection(
                    title: "Disponibilité",
                    icon: AppImage.Icon.checkCircle.image,
                    items: Availability.allCases.map { $0.description },
                    selection: $selectedAvailabilities
                )
                
                Spacer()
                
            }
            .padding(AppToken.Padding.screen)
        }
    }
}

#Preview {
    ZStack {
        Color.ink.ignoresSafeArea()

        WorkshopFilter(
            dates: ["02/09/2026", "03/09/2026", "04/09/2026", "05/09/2026", "06/09/2026"],
            categories: ["Danse", "Yoga", "Musique"]
        )
    }
}
