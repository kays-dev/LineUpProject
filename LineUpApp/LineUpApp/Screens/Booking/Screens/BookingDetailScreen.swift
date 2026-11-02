//
//  BookingDetailScreen.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

// Détail d'une réservation depuis l'Agenda (niveau 2) : récapitulatif, infos, statut, actions
struct BookingDetailScreen: View {
    
    let reservation: Reservation
    
    @Environment(ReservationStore.self) private var reservationStore
    
    var body: some View {
        BookingDetailContent(reservation: reservation, reservationStore: reservationStore)
    }
    
}

struct BookingDetailContent: View {
    
    @State private var viewModel: BookingDetailViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showActivityDetail = false
    @State private var showCancelPopup = false
    
    init(reservation: Reservation, reservationStore: ReservationStore) {
        _viewModel = State(initialValue: BookingDetailViewModel(
            reservation: reservation,
            reservationStore: reservationStore
        ))
    }
    
    var body: some View {
        
        ScrollView {
            
            VStack(alignment: .leading, spacing: Styles.sectionGap) {
                
                // Récapitulatif
                VStack(alignment: .leading, spacing: Styles.titleGap) {
                    
                    SectionTitle(title: "booking.summary")
                    
                    ContentCard(theme: .dark, size: .big) {
                        
                        VStack(spacing: Styles.infoGap){
                            
                            InfoRow(label: .bookingFullName, value: viewModel.reservation.userName)
                            InfoRow(label: .bookingSchedule, value: viewModel.schedule)
                            InfoRow(label: .bookingWorkshop, value: viewModel.workshop.name)
                            
                        }
                        
                    }
                    
                }
                
                // Infos complémentaires
                VStack(alignment: .leading, spacing: Styles.titleGap) {
                    
                    SectionTitle(title: "booking.moreInfo")
                    
                    ContentCard(theme: .dark, size: .big) {
                        
                        VStack(spacing: Styles.infoGap){
                            
                            if let accessibility = viewModel.accessibilityInstructions {
                                InfoRow(label: .bookingAccessibility, value: accessibility)
                            }

                            if let waitlist = viewModel.waitlistMessage {
                                InfoRow(label: .bookingWaitlist, value: waitlist)
                            }

                            if let meetingPoint = viewModel.meetingPoint {
                                InfoRow(label: .bookingMeetingPoint, value: meetingPoint)
                            }

                            InfoRow(label: .bookingCategory, value: viewModel.workshop.categoryName)
                            InfoRow(label: .bookingDuration, value: viewModel.duration)

                        }
                        
                    }
                    
                }
                
                // Statut
                VStack(alignment: .leading, spacing: Styles.titleGap) {
                    
                    SectionTitle(title: "booking.status")
                    
                    ProgressBar(status: viewModel.reservation.status, levels: viewModel.progressLevels)
                    
                }
                
                // Actions
                VStack(spacing: Styles.buttonsGap) {
                    
                    AppButton(title: "booking.workshopDetails", type: .primary, isFullWidth: true) {
                        showActivityDetail = true
                    }
                    
                    if viewModel.canCancel {
                        
                        AppButton(title: "common.cancel", type: .secondary, isFullWidth: true) {
                            showCancelPopup = true
                        }
                        
                    }
                    
                }
                
            }
            .foregroundStyle(Styles.foreground)
            .padding(.horizontal, AppToken.Padding.screen)
            .padding(.top, Styles.screenTopPadding)
            .padding(.bottom, Styles.screenBottomPadding)
            
        }
        .background(Styles.background)
        .scrollIndicators(.hidden)
        .lineupPageHeading(.secondary(title: .bookingNumber(viewModel.reservation.code))) {
            
            ShareLink(item: viewModel.shareText) {
                
                Styles.shareIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: Styles.shareIconSize, height: Styles.shareIconSize)
                    .foregroundStyle(AppColor.Button.Secondary.text)
                    .frame(width: Styles.shareButtonSize, height: Styles.shareButtonSize)
                    .background(AppColor.Button.Secondary.background)
                    .clipShape(Capsule())
                    .overlay {
                        Capsule()
                            .strokeBorder(AppColor.Button.Secondary.border, lineWidth: AppToken.Border.medium)
                    }
                
            }
            .accessibilityLabel(Text(.commonShare))
            
        }
        .tabBarVisibility(.hidden)
        .navigationDestination(isPresented: $showActivityDetail) {
            
            ActivityDetailScreen(workshop: viewModel.workshop) {
                showActivityDetail = false
            }
            .toolbar(.hidden, for: .navigationBar)
            
        }
        .fullScreenCover(isPresented: $showCancelPopup) {
            
            CancelBookingPopup(reservation: viewModel.reservation) {
                
                Task {

                    if await viewModel.cancel() {
                        dismiss()
                    }
                    
                }
                
            }
            
        }
        .fullScreenCover(isPresented: $viewModel.showsCancelError) {
            
            StatusPopup(
                type: .danger,
                title: String(localized: .bookingCancelErrorTitle),
                message: String(localized: .bookingCancelErrorMessage),
                buttonTitle: String(localized: .commonClose)
            ) {
                viewModel.showsCancelError = false
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .presentationBackground(Styles.background)
            
        }
        
    }
    
}

fileprivate struct Styles {
    
    static let background = AppColor.Screen.background
    static let foreground = AppColor.Text.primary
    
    static let sectionGap = AppToken.Spacing.s28
    static let titleGap = AppToken.Spacing.s8
    static let infoGap = AppToken.Spacing.s16
    static let buttonsGap = AppToken.Spacing.s8
    
    static let shareIcon = AppImage.Icon.share.image
    static let shareIconSize = AppToken.Scale.primitive24
    static let shareButtonSize = AppToken.Scale.primitive44
    
    static let screenTopPadding = AppToken.Padding.headerBottom
    static let screenBottomPadding = AppToken.Padding.scrollViewBottom
    static let screenHorizontalPadding = AppToken.Padding.screen
    
}

#Preview {
    
    NavigationStack {
        
        BookingDetailScreen(
            reservation: Reservation(
                id: 1025,
                status: .validated,
                workshop: Workshop(
                    id: UUID(),
                    name: "La dolce vita",
                    startTime: .now.addingTimeInterval(86_400),
                    endTime: .now.addingTimeInterval(86_400 + 10_800),
                    capacityMax: 40,
                    subscriberNumber: 40,
                    workshopDescription: "Consigne PSH|Séance en VOSTFR avec sous-titres SME. Emplacements fauteuil en bout de rangée.",
                    categoryID: UUID(),
                    categoryName: "Cinéma",
                    remainingPlaces: 0
                ),
                userName: "Giulia Rossi"
            )
        )
        
    }
    .environment(ReservationStore(service: ReservationService(apiClient: APIClient(baseURL: APIConfig.baseURL, keychain: KeychainService()))))
    
}
