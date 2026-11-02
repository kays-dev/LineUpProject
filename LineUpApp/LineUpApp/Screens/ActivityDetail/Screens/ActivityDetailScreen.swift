//
//  ActivityDetailScreen.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

struct ActivityDetailScreen: View {
    
    var workshop: Workshop
    
    var onReturnToPlanning: () -> Void
    
    var useTypes: UseTypes
    
    @State private var showReservationSuccessPopup = false
    
    var body: some View {
        
        ZStack {
            Color.mintPrimary
                .ignoresSafeArea()
            
            ScrollView {
                
                VStack(alignment: .center, spacing: AppToken.Scale.primitive28)
                {
                    
                    // navigation bar
                    PageHeading(
                        mode: .secondary(
                            title: LocalizedStringResource(
                                stringLiteral: workshop.name
                            )
                        )
                    ) {
                        ShareLink(item: workshop.description) {
                            AppImage.Icon.share.image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(AppColor.Button.Secondary.text)
                                .padding(AppToken.Padding.button)
                                .frame(width: 44, height: 44)
                                .background(
                                    AppColor.Button.Secondary.background
                                )
                                .clipShape(Capsule())
                                .overlay {
                                    Capsule()
                                        .stroke(
                                            AppColor.Button.Secondary.border,
                                            lineWidth: AppToken.Border.medium
                                        )
                                }
                        }
                        
                    }
                    
                    // card
                    BigCard(
                        cardFormat: workshop.availability == .available
                        ? .standard : .compact,
                        use: .workshop(workshop.availability),
                        workshopDate: workshop.date,
                        workshopStartTime: workshop.startTime,
                        workshopEndTime: workshop.endTime,
                        workshopCategory: workshop.categoryName,
                        workshopIcon: workshop.categoryIcon,
                        workshopName: workshop.name,
                        remainingPlaces: workshop.remainingPlaces,
                        capacityMax: workshop.capacityMax
                    )
                    
                    // capsule
                    HStack {
                        Spacer()
                        BadgeView(
                            title: workshop.categoryName,
                            availability: workshop.availability,
                            icon: workshop.categoryIcon
                        )
                    }
                    
                    // Description
                    if let section = workshop.descriptionSection(
                        name: "Description"
                    ) {
                        Text(section.detail)
                            .foregroundStyle(AppColor.Text.primary)
                    }
                    
                    if useTypes == .workshop {
                        
                        // Boutons
                        if workshop.remainingPlaces > 0 {
                            PrimaryButton(
                                text: "Réserver",
                                isSelected: true
                            ) {
                                showReservationSuccessPopup = true
                            }
                        } else {
                            AppButton(
                                title: "Rejoindre la liste d’attente",
                                type: .secondary,
                                tone: .danger
                            ) {
                                showReservationSuccessPopup = true
                                
                            }
                        }
                    }
                    
                }
                .padding(AppToken.Padding.screen)
                
                // -> popup + confetti
                .navigationDestination(
                    isPresented: $showReservationSuccessPopup
                ) {
                    ReservationSuccessPopup(
                        workshop: workshop,
                        onReturnToPlanning: onReturnToPlanning
                    )
                    .toolbar(.hidden, for: .navigationBar)
                    
                    
                }
            }
            
        }
    }
}

#Preview {
    ZStack {
        Color.mintPrimary
            .ignoresSafeArea()
        NavigationStack {
            ActivityDetailScreen(
                workshop: Workshop(
                    id: UUID(),
                    name: "Éternel Tintoret",
                    startTime: Date(),
                    endTime: Date().addingTimeInterval(3600),
                    capacityMax: 16,
                    subscriberNumber: 8,
                    workshopDescription:
                        "Description|Ateliers artistiques pour le jeune public, avec des activités de collage, dessin, découpage et création autour de Paris et Rome. Animés par Elisa Monguzzi (Ateliers du Poisson Bleu).",
                    categoryID: UUID(),
                    categoryName: "Jeune public",
                    remainingPlaces: 7,
                ),
                onReturnToPlanning: {},
                useTypes: .workshop
            )
        }
    }
}
