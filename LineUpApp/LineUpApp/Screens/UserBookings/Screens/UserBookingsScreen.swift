//
//  UserBookingsScreen.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

struct UserBookingsScreen: View {
    
    @Environment(ReservationStore.self) private var reservationStore
    @Environment(WorkshopStore.self) private var workshopStore
    @Environment(CategoryStore.self) private var categoryStore
    
    var body: some View {
        
        UserBookingsContent(reservationStore: reservationStore, workshopStore: workshopStore, categoryStore: categoryStore)
    }
    
}

struct UserBookingsContent: View {
    
    @State private var viewModel: UserBookingsViewModel
    
    @State private var selectedReservation: Reservation?
    @State private var reservationToCancel: Reservation?
    @State private var showFilters = false
    
    init(reservationStore: ReservationStore, workshopStore: WorkshopStore, categoryStore: CategoryStore) {
        
        _viewModel = State(initialValue: UserBookingsViewModel(
            reservationStore: reservationStore,
            workshopStore: workshopStore,
            categoryStore: categoryStore
        ))
        
    }
    
    var body: some View {
        
        List {
            if !viewModel.visibleReservations.isEmpty {
                
                SectionTitle(title: "agenda.section.ongoing")
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(Styles.firstSectionInsets)
                
                // En cours
                if !viewModel.ongoing.isEmpty {
                    
                    ScrollView(.horizontal) {
                        
                        HStack(spacing: AppToken.Spacing.s16) {
                            
                            ForEach(viewModel.ongoing) { reservation in
                                
                                BigCard(
                                    cardFormat: .ongoing,
                                    use: .reservation(reservation.status, availability: reservation.workshop.availability),
                                    workshopDate: reservation.workshop.startTime,
                                    workshopStartTime: reservation.workshop.startTime,
                                    workshopEndTime: reservation.workshop.endTime,
                                    workshopCategory: reservation.workshop.categoryName,
                                    workshopIcon: reservation.workshop.categoryIcon,
                                    workshopName: reservation.workshop.name,
                                    remainingPlaces: reservation.workshop.remainingPlaces,
                                    capacityMax: reservation.workshop.capacityMax
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedReservation = reservation
                                }
                                
                            }
                            
                        }
                        
                    }
                    .scrollIndicators(.hidden)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(Styles.rowInsets)
                    
                } else {
                    
                    ContentUnavailableView(
                        "Pas de réservations en cours", image: AppImage.InterfaceIcon.ellipsisDuotone.rawValue)
                    .foregroundStyle(Color.grayDarker)
                    .listRowBackground(Color.clear)
                }
                
                // À venir
                SectionTitle(title: "agenda.section.upcoming")
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(Styles.sectionInsets)
                
                if !viewModel.upcoming.isEmpty {

                    ForEach(viewModel.upcoming) { reservation in
                        
                        TicketRow(reservation: reservation) {
                            reservationToCancel = reservation
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedReservation = reservation
                        }
                        
                    }
                    
                } else {
                    
                    ContentUnavailableView(
                        "Pas de réservations à venir", image: AppImage.InterfaceIcon.ellipsisDuotone.rawValue
                    )
                    .foregroundStyle(Color.grayDark)
                    .listRowBackground(Color.clear)
                }
                
                // En liste d'attente
                
                SectionTitle(title: "agenda.section.waitlist")
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(Styles.sectionInsets)
                
                if !viewModel.waitlist.isEmpty {
                    
                    ForEach(viewModel.waitlist) { reservation in
                        
                        TicketRow(reservation: reservation) {
                            reservationToCancel = reservation
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedReservation = reservation
                        }
                        
                    }
                    
                } else {
                    
                    ContentUnavailableView(
                        "Pas de réservations à venir", image: AppImage.InterfaceIcon.ellipsisDuotone.rawValue
                    )
                    .foregroundStyle(Color.grayDark)
                    .listRowBackground(Color.clear)
                }
                
                // Annulées
                SectionTitle(title: "agenda.section.cancelled")
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(Styles.sectionInsets)
                
                if !viewModel.cancelled.isEmpty {
                    
                    ForEach(viewModel.cancelled) { reservation in
                        
                        TicketRow(reservation: reservation)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedReservation = reservation
                            }
                        
                    }
                    .padding(.bottom, Styles.screenBottomPadding)
                    
                }  else {
                    
                    ContentUnavailableView(
                        "Pas de réservations annulées", image: AppImage.InterfaceIcon.ellipsisDuotone.rawValue
                    )
                    .foregroundStyle(Color.grayDark)
                    .listRowBackground(Color.clear)
                }
                
            } else {
                
                ContentUnavailableView(
                    "Pas de réservations",
                    systemImage: "questionmark.folder"
                )
                .foregroundStyle(Color.grayDark)
                .listRowBackground(Color.clear)
            }
            
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .background(Styles.background)
        .safeAreaBar(edge: .top, content: {
            
            HStack(spacing: Styles.searchGap) {
                
                SearchBar(input: $viewModel.query)
                
                AppButton(title: "filters.title", icon: Styles.filterIcon, type: .iconOutline, shape: .radius16) {
                    showFilters = true
                }
                
            }
            .padding(.bottom, Styles.screenTopPadding)
            .padding(.horizontal, Styles.screenHorizontalPadding)
            
        })
        .lineupPageHeading(.primary(heading: .agendaTitle)) {
            LanguageFlagButton()
        }
        .navigationDestination(item: $selectedReservation) { reservation in
            
            BookingDetailScreen(reservation: reservation)
            
        }
        .fullScreenCover(item: $reservationToCancel) { reservation in
            
            CancelBookingPopup(reservation: reservation) {
                
                Task {
                    await viewModel.cancel(reservation)
                }
                
            }
            
        }
        .fullScreenCover(isPresented: $showFilters) {
            
            WorkshopFilterScreen(
                viewModel: viewModel.filters,
                dates: viewModel.filterDays,
                categories: viewModel.filterCategories,
                onConfirm: {}
            )
            
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
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.refresh()
        }
        
    }
    
}

fileprivate struct Styles {
    
    static let background = AppColor.Screen.background
    
    static let searchGap = AppToken.Spacing.s16
    static let filterIcon = AppImage.Icon.sort.image
    
    static let rowInsets = AppToken.Padding.reservationRow
    static let firstSectionInsets = EdgeInsets(top: AppToken.Spacing.none, leading: AppToken.Padding.screen, bottom: AppToken.Spacing.none, trailing: AppToken.Padding.screen)
    static let sectionInsets = EdgeInsets(top: AppToken.Spacing.s20, leading: AppToken.Padding.screen, bottom: AppToken.Spacing.none, trailing: AppToken.Padding.screen)
    
    static let screenTopPadding = AppToken.Padding.headerBottom
    static let screenBottomPadding = AppToken.Padding.scrollViewBottom
    static let screenHorizontalPadding = AppToken.Padding.screen
    
}

#Preview {
    
    let apiClient = APIClient(baseURL: APIConfig.baseURL, keychain: KeychainService())
    
    NavigationStack {
        UserBookingsScreen()
    }
    .environment(ReservationStore(service: ReservationService(apiClient: apiClient)))
    .environment(WorkshopStore(workshopService: WorkshopService(apiClient: apiClient)))
    .environment(CategoryStore(service: CategoryService(apiClient: apiClient)))
    
}
