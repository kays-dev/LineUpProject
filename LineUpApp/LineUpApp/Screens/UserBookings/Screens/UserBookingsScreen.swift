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

            // En cours
            if !viewModel.ongoing.isEmpty {

                SectionTitle(title: "agenda.section.ongoing")
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(Styles.sectionInsets)
                    .padding(.top, Styles.screenTopPadding)

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
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(Styles.rowInsets)
                            
                        }
                        
                    }
                    
                }

            }

            // À venir
            if !viewModel.upcoming.isEmpty {

                SectionTitle(title: "agenda.section.upcoming")
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(Styles.sectionInsets)

                ForEach(viewModel.upcoming) { reservation in

                    TicketRow(reservation: reservation) {
                        reservationToCancel = reservation
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedReservation = reservation
                    }

                }

            }

            // En liste d'attente
            if !viewModel.waitlist.isEmpty {

                SectionTitle(title: "agenda.section.waitlist")
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(Styles.sectionInsets)

                ForEach(viewModel.waitlist) { reservation in

                    TicketRow(reservation: reservation) {
                        reservationToCancel = reservation
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedReservation = reservation
                    }

                }

            }
            
            // Annulées
            if !viewModel.cancelled.isEmpty {

                SectionTitle(title: "agenda.section.cancelled")
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(Styles.sectionInsets)

                ForEach(viewModel.cancelled) { reservation in

                    TicketRow(reservation: reservation)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedReservation = reservation
                        }

                }

            }

        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .padding(.bottom, Styles.screenBottomPadding)
        .background(Styles.background)
        .safeAreaBar(edge: .top, content: {
            
            HStack(spacing: Styles.searchGap) {

                SearchBar(input: $viewModel.query)

                AppButton(title: "filters.title", icon: Styles.filterIcon, type: .iconOutline, shape: .radius16) {
                    showFilters = true
                }

            }
            .padding(.top, Styles.screenTopPadding)
            .padding(.horizontal, Styles.screenHorizontalPadding)
            
        })
        .lineupPageHeading(.primary(heading: .agendaTitle)) {}
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
