//
//  FilterSectionDateCategory.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import SwiftUI

struct FilterSectionDateCategory: View {

    let title: String
    let icon: Image
    let items: [String]

    @Binding var selection: Set<String>
    @Bindable var viewModel: WorkshopFiltersViewModel

    private let columns = [
        GridItem(.adaptive(minimum: 120), spacing: AppToken.Spacing.s12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: AppToken.Spacing.s16) {

            // Titre de section
            FilterHeader(
                title: title,
                icon: icon,
                font: AppFont.Label.label.font
            )

            // capsules date ou cétagories
            LazyVGrid(columns: columns, spacing: AppToken.Spacing.s12) {
                ForEach(items, id: \.self) { item in
                    FilterCapsule(
                        title: viewModel.formatDate(item),
                        isSelected: selection.contains(item)
                    )
                    .lineLimit(1)
                    .onTapGesture {
                        if selection.contains(item) {
                            selection.remove(item)
                        } else {
                            selection.insert(item)
                        }
                    }
                }
            }
            FilterButtonReset {
                selection.removeAll()
            }
        }
    }
}

#Preview {
    @Previewable @State var selection: Set<String> = ["Danse", "Musique"]
    
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
        Color.ink
            .ignoresSafeArea()

        FilterSectionDateCategory(
            title: "Catégories",
            icon: AppImage.Icon.sparkles.image,
            items: ["Danse", "Yoga", "Musique", "Théâtre", "Cirque"],
            selection: $selection,
            viewModel : viewModel
        )
        .padding()
    }
}
