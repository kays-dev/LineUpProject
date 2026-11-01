//
//  FilterSectionDates.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import SwiftUI

struct FilterSectionAvailability: View {

    
    @Binding var selection: Availability?
    @Bindable var viewModel: WorkshopFiltersViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppToken.Spacing.s16) {

            // Titre
            FilterHeader(
                title: "Disponibilité",
                icon: AppImage.Icon.checkCircle.image,
                font: AppFont.Label.label.font
            )

            // capsules
            HStack(spacing: AppToken.Spacing.s12) {
                ForEach(Availability.allCases, id: \.self) { availability in

                    FilterCapsule(
                        title: availability.description,
                        isSelected: selection == availability
                    )
                    // état de la capsule
                    .onTapGesture {
                        if selection == availability {
                            selection = nil
                        } else {
                            selection = availability
                        }
                    }
                }
            }
            FilterButtonReset(viewModel: viewModel)
        }
    }
}

#Preview {
    @Previewable @State var selection: Availability? = .available

    let viewModel = WorkshopFiltersViewModel(
        workshopStore: WorkshopStore(
            workshopService: WorkshopService(
                apiClient: APIClient(
                    baseURL: URL(string: "http://localhost:8080")!,
                    keychain: KeychainService()
                )
            )
        )
    )

    ZStack {
        Color.ink.ignoresSafeArea()

        FilterSectionAvailability(
            selection: $selection,
            viewModel: viewModel
        )
        .padding()
    }
}
