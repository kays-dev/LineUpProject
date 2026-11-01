//
//  ProfileScreen.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

struct ProfileScreen: View {

    @State private var viewModel: ProfileViewModel
    @Environment(SessionStore.self) private var sessionStore
    @AppStorage("selectedAvatar") private var avatar: AppImage.Avatar = .colombina

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
    }

    private var header: some View {
        HStack {
            HStack(spacing: AppToken.Spacing.none) {
                Text("profile.title")
                    .foregroundStyle(AppColor.Logo.text)
                Text(verbatim: ".")
                    .foregroundStyle(AppColor.Logo.dot)
            }
            .lineupFont(AppFont.Title.heading)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)

            Spacer()

            HStack(spacing: AppToken.Spacing.s12) {
                AppButton(title: "settings.title", icon: AppImage.Icon.settings.image, type: .iconOutline) {}
                AppImage.Flag.italian.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: AppToken.Scale.primitive28, height: AppToken.Scale.primitive28)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, AppToken.Padding.screen)
        .padding(.bottom, AppToken.Padding.headerBottom)
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
            sectionTitle("profile.stats")

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: AppToken.Spacing.s12),
                    GridItem(.flexible())
                ],
                spacing: AppToken.Spacing.s12
            ) {
                StatCard(
                    valueInString: "\(viewModel.reservationCount)",
                    label: String(localized: "stats.bookings"),
                    icon: .ticket
                )
                StatCard(
                    valueInString: "\(viewModel.attendedCount)",
                    label: String(localized: "stats.attended"),
                    icon: .calendarCheck
                )
                StatCard(
                    valueInString: viewModel.hoursSpentText,
                    label: String(localized: "stats.timeSpent"),
                    icon: .clock
                )
                StatCard(
                    valueInString: viewModel.favoriteCategory ?? "—",
                    label: String(localized: "stats.favoriteCategory"),
                    icon: .mask
                )
                StatCard(
                    valueInString: viewModel.festivalDaysText,
                    label: String(localized: "stats.festivalDays"),
                    icon: .calendar
                )
                StatCard(
                    valueInString: "\(viewModel.placesVisitedCount)",
                    label: String(localized: "stats.placesVisited"),
                    icon: .mapPin
                )
            }
        }
    }

    private var history: some View {
        VStack(alignment: .leading, spacing: AppToken.Spacing.s8) {
            sectionTitle("history.title")

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
                }
            }
        }
    }

    private func sectionTitle(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .lineupFont(AppFont.Body.section)
            .foregroundStyle(AppColor.Text.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    let keychain = KeychainService()
    let apiClient = APIClient(baseURL: APIConfig.baseURL, keychain: keychain)

    ProfileScreen(
        reservationStore: ReservationStore(service: ReservationService(apiClient: apiClient)),
        workshopStore: WorkshopStore(workshopService: WorkshopService(apiClient: apiClient))
    )
    .environment(SessionStore(service: AuthService(apiClient: apiClient, keychain: keychain)))
}
