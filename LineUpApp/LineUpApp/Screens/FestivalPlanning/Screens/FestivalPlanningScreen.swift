//
//  FestivalPlanningScreen.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import SwiftUI

struct FestivalPlanningScreen: View {

    @Bindable var viewModel: WorkshopFiltersViewModel
    @State private var selectedWorkshopID: UUID?
    @State private var showFilters = false

    var body: some View {
        ZStack {
            Color.mintPrimary.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppToken.Spacing.s16) {

                    // état vide
                    if viewModel.workshops.isEmpty && !viewModel.isLoading {
                        Group {
                            if viewModel.searchText.isEmpty {
                                ContentUnavailableView(
                                    "Aucun atelier",
                                    systemImage: "calendar.badge.exclamationmark"
                                )
                            } else {
                                ContentUnavailableView.search(
                                    text: viewModel.searchText
                                )
                            }
                        }
                        .font(AppFont.Title.title2.font.uppercaseSmallCaps())
                        .foregroundStyle(AppColor.Text.tertiary)
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
                .padding(.horizontal, AppToken.Padding.screen)
                .padding(.bottom, AppToken.Padding.scrollViewBottom)
            }
            .safeAreaBar(edge: .top) {

                // searchBar + bouton filtres
                HStack(spacing: AppToken.Spacing.s16) {
                    SearchBar(input: $viewModel.searchText)

                    AppButton(
                        title: "filters.title",
                        icon: AppImage.Icon.sort.image,
                        type: .iconOutline,
                        shape: ButtonShape.radius16
                    ) {
                        showFilters = true
                    }
                }
                .padding(.bottom, AppToken.Padding.headerBottom)
                .padding(.horizontal, AppToken.Padding.screen)
            }
            // en tête
            .lineupPageHeading(.primary(heading: "à l’affiche")) {
                LanguageFlagButton()
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

    return NavigationStack {
        FestivalPlanningScreen(viewModel: viewModel)
    }
}
