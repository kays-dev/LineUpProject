//
//  WorkshopFilterScreen.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import SwiftUI

struct WorkshopFilterScreen: View {

    @Bindable var viewModel: WorkshopFiltersViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var errorMessage: String?

    let dates: [String]
    let categories: [String]

    var onConfirm: (() -> Void)? = nil

    var body: some View {

        ZStack {
            Color.ink
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppToken.Spacing.s32) {

                    // en tête (titre + retour)
                    HStack {
                        FilterHeader(
                            title: "Filtres",
                            icon: AppImage.Icon.filter.image,
                            font: AppFont.Title.heading.font
                        )

                        Spacer()

                        AppButton(
                            icon: AppImage.InterfaceIcon.xMark.image,
                            type: .iconFilled
                        ) {
                            viewModel.resetFilters()
                            dismiss()
                        }
                    }

                    // Date
                    FilterSectionDateCategory(
                        title: "Dates",
                        icon: AppImage.Icon.calendar.image,
                        items: dates,
                        selection: $viewModel.selectedPeriods,
                        viewModel: viewModel
                    )

                    // Catégories
                    FilterSectionDateCategory(
                        title: "Catégories",
                        icon: AppImage.Icon.sparkles.image,
                        items: categories,
                        selection: $viewModel.selectedCategories,
                        viewModel: viewModel
                    )

                    // disponibilité
                    FilterSectionAvailability(
                        selection: $viewModel.selectedAvailability
                    )

                    // Bouton confirmer
                    PrimaryButton(
                        text: "Confirmer",
                        border: AppColor.Text.secondary,
                        isSelected: true,
                        action: {

                            if let onConfirm {
                                onConfirm()
                                dismiss()
                                return
                            }

                            Task {
                                do {
                                    try await viewModel.applyFilters()
                                    print("Filtres appliqués avec succès")
                                    dismiss()
                                } catch {
                                    errorMessage =
                                        "Impossible d'appliquer les filtres."
                                }
                            }
                        }
                    )

                    if let errorMessage {
                        Text(errorMessage)
                            .font(AppFont.Label.label.font)
                            .foregroundStyle(AppColor.Text.primary)
                    }

                    // bouton annuler
                    CancelledModalButton(
                        text: "Annuler",
                        isSelected: true,
                        action: {
                            viewModel.cancelChanges()
                            dismiss()
                        }
                    )
                }
                .padding(AppToken.Padding.screen)
            }
        }
        // couvre tous les cas où l’utilisateur quitte sans confirmer
        .onDisappear { viewModel.cancelChanges() }
    }
}

#Preview {
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

        WorkshopFilterScreen(
            viewModel: viewModel,
            dates: [
                "2026-11-01",
                "2026-11-02",
                "2026-11-03",
            ],
            categories: [
                "Danse",
                "Musique",
                "Théâtre",
                "Cirque",
            ]
        )
    }
}
