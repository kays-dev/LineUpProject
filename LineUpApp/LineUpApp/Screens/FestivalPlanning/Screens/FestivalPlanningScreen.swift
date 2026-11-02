//
//  FestivalPlanningScreen.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import SwiftUI

struct FestivalPlanningScreen: View {
    @Bindable var viewModel: WorkshopFiltersViewModel
    @State private var selectedWorkshop: Workshop?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mintPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        PageHeading(mode: .primary(heading: "à l’affiche")) {}

                        ForEach(viewModel.workshops) { workshop in
                            VStack(
                                alignment: .leading,
                                spacing: AppToken.Spacing.s16
                            ) {
                                SmallCard(
                                    cardFormat: .standard,
                                    use: .workshop(workshop.availability),
                                    workshopDate: workshop.date,
                                    workshopStartTime: workshop.startTime,
                                    workshopEndTime: workshop.endTime,
                                    workshopCategory: workshop.categoryName,
                                    workshopName: workshop.name
                                )
                            }
                            .onTapGesture {
                                selectedWorkshop = workshop
                            }
                        }
                    }
                    .padding(AppToken.Padding.screen)
                }
                .navigationDestination(item: $selectedWorkshop) { workshop in
                    ActivityDetailScreen(
                        workshop: workshop,
                        onReturnToPlanning: {
                            selectedWorkshop = nil
                        },
                        useTypes: .workshop
                    )
                }
            }
        }
    }
}

#Preview {

    let store = WorkshopStore(
        workshopService: WorkshopService(
            apiClient: APIClient(
                baseURL: URL(string: "http://localhost:8080")!,
                keychain: KeychainService()
            )
        )
    )

    let viewModel = WorkshopFiltersViewModel(workshopStore: store)

    return FestivalPlanningScreen(
        viewModel: viewModel
    )
}
