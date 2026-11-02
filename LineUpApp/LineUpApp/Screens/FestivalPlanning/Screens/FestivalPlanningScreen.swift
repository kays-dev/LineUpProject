//
//  FestivalPlanningScreen.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

struct FestivalPlanningScreen: View {
    @State private var showActivityDetail = false

    var body: some View {
        NavigationStack {
            VStack {
                Button("Voir le détail de l'atelier") {
                    showActivityDetail = true
                }
            }
            .navigationDestination(isPresented: $showActivityDetail) {
                ActivityDetailScreen(
                    workshop: Workshop(
                        id: UUID(),
                        name: "Atelier théâtre",
                        startTime: .now,
                        endTime: .now.addingTimeInterval(3600),
                        capacityMax: 20,
                        subscriberNumber: 10,
                        workshopDescription: "Découverte du théâtre",
                        categoryID: UUID(),
                        categoryName: "Théâtre",
                        remainingPlaces: 10
                    ),
                        onReturnToPlanning: {
                            showActivityDetail = false
                        }
                ).toolbar(.hidden, for: .navigationBar)
            }
        }
    }
}

#Preview {
    FestivalPlanningScreen()
}
