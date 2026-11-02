//
//  FestivalPlanningScreen.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import SwiftUI

struct FestivalPlanningScreen: View {

@Bindable var viewModel: WorkshopFiltersViewModel
@State private var isItalianFlag = true
@State private var selectedWorkshopID: UUID?
@State private var showFilters = false

var body: some View {
        NavigationStack {
            ZStack {
                Color.mintPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppToken.Spacing.s28) {

                        // en tête
                        PageHeading(mode: .primary(heading: "à l’affiche")) {
                            Button {
                                isItalianFlag.toggle()
                            } label: {
                                if isItalianFlag {
                                    AppImage.Flag.italian.image
                                        .resizable()
                                        .scaledToFit()
                                } else {
                                    AppImage.Flag.french.image
                                        .resizable()
                                        .scaledToFit()
                                }
                            }
                            .buttonStyle(.plain)
                        }

                        // searchBar + bouton filtres
                        HStack(spacing: AppToken.Spacing.s16) {
                            SearchBar(input: $viewModel.searchText)

                            AppButton(
                                title: "filters.title",
                                icon: AppImage.Icon.filter.image,
                                type: .iconOutline,
                                shape: ButtonShape.round
                            ) {
                                showFilters = true
                            }
                        }

                        // état vide
                        if viewModel.workshops.isEmpty && !viewModel.isLoading {
                            ContentUnavailableView.search(
                                text: viewModel.searchText
                            )
                        }

                        // cards
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
                                selectedWorkshopID = workshop.id
                            }
                        }
                    }
                    .padding(AppToken.Padding.screen)
                    .padding(.top, AppToken.Padding.headerBottom)
                    .padding(.bottom, AppToken.Padding.scrollViewBottom)
                }
                .navigationDestination(isPresented: $showFilters) {
                    WorkshopFilterScreen(
                        viewModel: viewModel,
                        dates: viewModel.availableDays,
                        categories: viewModel.availableCategories
                    )
                    .toolbar(.hidden, for: .navigationBar)
                }
                .navigationDestination(item: $selectedWorkshopID) { id in
                    if let workshop = viewModel.workshop(id: id) {
                        ActivityDetailScreen(
                            workshop: workshop,
                            onReturnToPlanning: { selectedWorkshopID = nil },
                            useTypes: .workshop
                        )
                        .toolbar(.hidden, for: .navigationBar)
                    } else {
                        ContentUnavailableView(
                            "Atelier introuvable",
                            systemImage: "questionmark.folder"
                        )
                    }
                }
                .toolbar(.hidden, for: .navigationBar)
            }
            .task(id: viewModel.searchText) {
                await viewModel.search()
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

    return FestivalPlanningScreen(viewModel: viewModel)
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
