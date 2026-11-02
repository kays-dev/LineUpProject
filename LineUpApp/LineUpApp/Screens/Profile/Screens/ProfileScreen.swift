//
//  ProfileScreen.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

struct ProfileScreen: View {

    @Environment(ReservationStore.self) private var reservationStore
    @Environment(WorkshopStore.self) private var workshopStore

    var body: some View {
        ProfileContent(reservationStore: reservationStore, workshopStore: workshopStore)
    }
}

struct ProfileContent: View {

    @State private var viewModel: ProfileViewModel
    @Environment(SessionStore.self) private var sessionStore
    @AppStorage("selectedAvatar") private var avatar: AppImage.Avatar = .colombina
    @AppStorage("appLanguage") private var language: AppLanguage = .french
    @Environment(\.locale) private var locale
    @State private var showsSettings = false
    @State private var selectedReservation: Reservation?

    init(reservationStore: ReservationStore, workshopStore: WorkshopStore) {
        _viewModel = State(initialValue: ProfileViewModel(
            reservationStore: reservationStore,
            workshopStore: workshopStore
        ))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppToken.Spacing.s28) {
                identity
                stats
                history
            }
            .padding(.horizontal, AppToken.Padding.screen)
            .padding(.bottom, AppToken.Padding.scrollViewBottom)
        }
        .safeAreaBar(edge: .top) {
            header
        }
        .background(AppColor.Screen.background)
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .task {
            await viewModel.loadProfile()
        }
        .navigationDestination(isPresented: $showsSettings) {
            SettingsScreen()
        }
        .navigationDestination(item: $selectedReservation) { reservation in

            BookingDetailScreen(reservation: reservation)

        }
    }

    private var header: some View {
        HStack {
            PageTitle(title: "profile.title")

            Spacer()

            HStack(spacing: AppToken.Spacing.s12) {
                AppButton(title: "settings.title", icon: AppImage.Icon.settings.image, type: .iconOutline) {
                    showsSettings = true
                }
                Button {
                    language = language == .italian ? .french : .italian
                } label: {
                    flag.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: AppToken.Scale.primitive28, height: AppToken.Scale.primitive28)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("settings.language"))
            }
        }
        .padding(.horizontal, AppToken.Padding.screen)
        .padding(.bottom, AppToken.Padding.headerBottom)
    }

    private func localized(_ key: String.LocalizationValue) -> String {
        String(localized: LocalizedStringResource(key, locale: locale))
    }

    private var flag: AppImage.Flag {
        language == .italian ? .french : .italian
    }

    private var identity: some View {
        VStack(spacing: AppToken.Spacing.s8) {
            avatar.image
                .resizable()
                .scaledToFill()
                .frame(width: AppToken.Avatar.preview, height: AppToken.Avatar.preview)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .strokeBorder(AppColor.AvatarPicker.photoBorder, lineWidth: AppToken.Border.medium)
                }
                .frame(width: AppToken.Avatar.previewRing, height: AppToken.Avatar.previewRing)
                .background {
                    Circle()
                        .fill(AppColor.AvatarPicker.previewBackground)
                }
                .overlay {
                    Circle()
                        .strokeBorder(AppColor.AvatarPicker.selectedRing, lineWidth: AppToken.Border.medium)
                }
                .accessibilityHidden(true)

            if let user = sessionStore.user {
                Text(user.name)
                    .lineupFont(AppFont.Title.title)
                    .foregroundStyle(AppColor.Text.primary)
                Text(user.email)
                    .lineupFont(AppFont.Body.body)
                    .foregroundStyle(AppColor.Text.tertiary)
            }
        }
    }

    private var stats: some View {
        VStack(alignment: .leading, spacing: AppToken.Spacing.s8) {
            SectionTitle(title: "profile.stats")

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: AppToken.Spacing.s12),
                    GridItem(.flexible())
                ],
                spacing: AppToken.Spacing.s12
            ) {
                StatCard(
                    valueInString: "\(viewModel.reservationCount)",
                    label: localized("stats.bookings"),
                    icon: AppImage.InterfaceIcon.ticketFill.image
                )
                StatCard(
                    valueInString: "\(viewModel.attendedCount)",
                    label: localized("stats.attended"),
                    icon: AppImage.InterfaceIcon.calendarCheckFill.image
                )
                StatCard(
                    valueInString: viewModel.hoursSpentText,
                    label: localized("stats.timeSpent"),
                    icon: AppImage.InterfaceIcon.clockFill.image
                )
                StatCard(
                    valueInString: viewModel.favoriteCategory ?? "—",
                    label: localized("stats.favoriteCategory"),
                    icon: AppImage.InterfaceIcon.maskFill.image
                )
                StatCard(
                    valueInString: viewModel.festivalDaysText,
                    label: localized("stats.festivalDays"),
                    icon: AppImage.InterfaceIcon.calendarFill.image
                )
                StatCard(
                    valueInString: "\(viewModel.placesVisitedCount)",
                    label: localized("stats.placesVisited"),
                    icon: AppImage.InterfaceIcon.mapPinFill.image
                )
            }
        }
    }

    private var history: some View {
        VStack(alignment: .leading, spacing: AppToken.Spacing.s8) {
            SectionTitle(title: "history.title")

            VStack(spacing: AppToken.Spacing.s12) {
                ForEach(viewModel.history) { reservation in
                    SmallCard(
                        cardFormat: .booked,
                        use: .reservation(reservation.status, availability: reservation.workshop.availability),
                        workshopDate: reservation.workshop.startTime,
                        workshopStartTime: reservation.workshop.startTime,
                        workshopEndTime: reservation.workshop.endTime,
                        workshopCategory: reservation.workshop.categoryName,
                        workshopName: reservation.workshop.name
                    )
                    .onTapGesture {
                        selectedReservation = reservation
                    }
                }
            }
        }
    }
}

#Preview {
    let keychain = KeychainService()
    let apiClient = APIClient(baseURL: APIConfig.baseURL, keychain: keychain)

    ProfileScreen()
        .environment(ReservationStore(service: ReservationService(apiClient: apiClient)))
        .environment(WorkshopStore(workshopService: WorkshopService(apiClient: apiClient)))
        .environment(SessionStore(service: AuthService(apiClient: apiClient, keychain: keychain)))
}
