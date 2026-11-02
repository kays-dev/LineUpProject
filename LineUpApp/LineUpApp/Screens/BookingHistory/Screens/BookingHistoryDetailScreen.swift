//
//  BookingHistoryDetailScreen.swift
//  LineUpApp
//
//  Created by Apprenant174 on 02/11/2026.
//

import SwiftUI

// Détail d'une réservation passée (niveau 3) : deux accordéons, « Réservation » ouvert, « Détails de l'atelier » fermé
struct BookingHistoryDetailScreen: View {
    
    let reservation: Reservation
    
    @State private var isReservationOpen = true
    @State private var isWorkshopOpen = false
    
    private var workshop: Workshop {
        reservation.workshop
    }
    
    var body: some View {
        
        ScrollView {
            
            VStack(alignment: .leading, spacing: Styles.sectionGap) {
                
                // Accordéon : Réservation
                Button {
                    
                    withAnimation(.snappy) { isReservationOpen.toggle() }
                    
                } label: {
                    
                    HStack {
                        
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            
                            Text(".").foregroundStyle(Styles.dotColor)
                            Text(.bookingNumber(reservation.code))
                            
                        }
                        .lineupFont(Styles.accordionFont)
                        
                        Spacer()
                        
                        Styles.chevron
                            .rotationEffect(.degrees(isReservationOpen ? 90 : 0))
                        
                    }
                    .contentShape(Rectangle())
                    
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(.isHeader)
                
                if isReservationOpen {
                    
                    // Récapitulatif
                    VStack(alignment: .leading, spacing: Styles.titleGap) {
                        
                        SectionTitle(title: "booking.summary")
                        
                        ContentCard(theme: .dark, size: .big) {
                            
                            VStack(spacing: Styles.infoGap){
                                
                                InfoRow(label: .bookingFullName, value: reservation.userName)
                                InfoRow(label: .bookingSchedule, value: workshop.startTime.scheduleText(until: workshop.endTime))
                                InfoRow(label: .bookingWorkshop, value: workshop.name)
                                
                            }
                            
                        }
                        
                    }
                    
                    // Infos complémentaires
                    VStack(alignment: .leading, spacing: Styles.titleGap) {
                        
                        SectionTitle(title: "booking.moreInfo")
                        
                        ContentCard(theme: .dark, size: .big) {
                            
                            VStack(spacing: Styles.infoGap){
                                
                                if let accessibility = workshop.descriptionSection(name: Styles.accessibilitySection) {
                                    InfoRow(label: .bookingAccessibility, value: accessibility.detail)
                                }
                                
                                if let waitlist = workshop.descriptionSection(name: Styles.waitlistSection) {
                                    InfoRow(label: .bookingWaitlist, value: waitlist.detail)
                                }
                                
                                if let meetingPoint = workshop.descriptionSection(name: Styles.meetingPointSection) {
                                    InfoRow(label: .bookingMeetingPoint, value: meetingPoint.detail)
                                }
                                
                                InfoRow(label: .bookingCategory, value: workshop.categoryName)
                                InfoRow(label: .bookingDuration, value: workshop.startTime.durationText(until: workshop.endTime))
                                
                            }
                            
                        }
                        
                    }
                    
                    // Statut final
                    HStack(spacing: Styles.statusGap) {
                        
                        Styles.statusIcon(reservation.status)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Styles.iconSize, height: Styles.iconSize)
                            .foregroundStyle(Styles.statusColor(reservation.status))
                            .padding(Styles.iconPadding)
                            .background {
                                
                                Circle()
                                    .fill(Styles.statusFill(reservation.status))
                                    .strokeBorder(Styles.statusColor(reservation.status), lineWidth: Styles.iconLineWidth)
                                
                            }
                        
                        VStack(alignment: .leading, spacing: Styles.statusTextGap) {
                            
                            Text(.historyFinished)
                                .lineupFont(Styles.statusTitleFont)
                            
                            Text(reservation.status == .validated ? .historyWasApproved : .bookingStatusCancelled)
                                .lineupFont(Styles.statusFont)
                            
                        }
                        
                        Spacer(minLength: 0)
                        
                    }
                    .padding(Styles.statusPadding)
                    .background {
                        
                        RoundedRectangle(cornerRadius: Styles.statusCornerRadius)
                            .fill(Styles.statusBackground)
                            .strokeBorder(Styles.statusBorder, lineWidth: Styles.statusLineWidth)
                        
                    }
                    .accessibilityElement(children: .combine)
                    
                }
                
                // Accordéon : Détails de l'atelier
                Button {
                    
                    withAnimation(.snappy) { isWorkshopOpen.toggle() }
                    
                } label: {
                    
                    HStack {
                        
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            
                            Text(".").foregroundStyle(Styles.dotColor)
                            Text(.bookingWorkshopDetails)
                            
                        }
                        .lineupFont(Styles.accordionFont)
                        
                        Spacer()
                        
                        Styles.chevron
                            .rotationEffect(.degrees(isWorkshopOpen ? 90 : 0))
                        
                    }
                    .contentShape(Rectangle())
                    
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(.isHeader)
                
                if isWorkshopOpen {
                    
                    BigCard(
                        cardFormat: .compact,
                        use: .reservation(reservation.status, availability: workshop.availability),
                        workshopDate: workshop.startTime,
                        workshopStartTime: workshop.startTime,
                        workshopEndTime: workshop.endTime,
                        workshopCategory: workshop.categoryName,
                        workshopIcon: workshop.categoryIcon,
                        workshopName: workshop.name,
                        remainingPlaces: workshop.remainingPlaces,
                        capacityMax: workshop.capacityMax
                    )
                    
                    if let description = workshop.descriptionSection(name: Styles.descriptionSection) {
                        
                        Text(description.detail)
                            .lineupFont(Styles.descriptionFont)
                        
                    }
                    
                }
                
            }
            .foregroundStyle(Styles.foreground)
            .padding(.horizontal, Styles.screenHorizontalPadding)
            .padding(.top, Styles.screenTopPadding)
            .padding(.bottom, Styles.screenBottomPadding)
            
        }
        .background(Styles.background)
        .scrollIndicators(.hidden)
        .lineupPageHeading(.secondary(title: LocalizedStringResource(stringLiteral: workshop.name))) {
            
            ShareLink(item: String(localized: .bookingNumber(reservation.code)) + " · " + workshop.name) {
                
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
        
    }
    
}

fileprivate struct Styles {
    
    static let background = AppColor.Screen.background
    static let foreground = AppColor.Text.primary
    static let dotColor = Color.redPrimary
    
    static let accordionFont: AppFont = .Title.title
    static let descriptionFont: AppFont = .Body.body
    static let statusTitleFont: AppFont = .Title.title2
    static let statusFont: AppFont = .Body.body2
    
    static let sectionGap = AppToken.Spacing.s28
    static let titleGap = AppToken.Spacing.s8
    static let infoGap = AppToken.Spacing.s16
    
    static let screenTopPadding = AppToken.Padding.headerBottom
    static let screenBottomPadding = AppToken.Padding.scrollViewBottom
    static let screenHorizontalPadding = AppToken.Padding.screen
    
    static let chevron = AppImage.Icon.forward.image
    
    // Sections de la description de l'API
    static let accessibilitySection = "Consigne PSH"
    static let waitlistSection = "Liste d’attente"
    static let meetingPointSection = "Point de RDV"
    static let descriptionSection = "Description"
    
    // Carte « Atelier terminé »
    static let statusGap = AppToken.Spacing.s16
    static let statusTextGap = AppToken.Spacing.s4
    static let statusPadding = AppToken.Spacing.s16
    static let statusCornerRadius = AppToken.Radius.small
    static let statusBackground = AppColor.Card.Standard.background
    static let statusBorder = AppColor.Card.Standard.border
    static let statusLineWidth = AppToken.Border.thin
    
    static let iconSize = AppToken.Scale.primitive24
    static let iconPadding = AppToken.Spacing.s12
    static let iconLineWidth = AppToken.Border.medium
    
    static func statusIcon(_ status: ReservationStatus) -> Image {
        status == .validated ? AppImage.InterfaceIcon.ticketDuotone.image : AppImage.InterfaceIcon.xMark.image
    }
    
    static func statusColor(_ status: ReservationStatus) -> Color {
        status == .validated ? Color.validationDark : Color.dangerDark
    }
    
    static func statusFill(_ status: ReservationStatus) -> Color {
        status == .validated ? Color.validationLight : Color.dangerLight
    }
    
    static let shareIcon = AppImage.Icon.share.image
    static let shareIconSize = AppToken.Scale.primitive24
    static let shareButtonSize = AppToken.Scale.primitive44
    
}

#Preview {
    
    NavigationStack {
        
        BookingHistoryDetailScreen(
            reservation: Reservation(
                id: 1021,
                status: .validated,
                workshop: Workshop(
                    id: UUID(),
                    name: "L'atelier des enfants",
                    startTime: .now.addingTimeInterval(-86_400),
                    endTime: .now.addingTimeInterval(-86_400 + 9_000),
                    capacityMax: 16,
                    subscriberNumber: 16,
                    workshopDescription: "Description|Ateliers artistiques pour le jeune public, avec des activités de collage, dessin, découpage et création autour de Paris et Rome. § Consigne PSH|Atelier adapté aux enfants en situation de handicap : matériel ergonomique et animateur dédié sur demande.",
                    categoryID: UUID(),
                    categoryName: "Jeune public",
                    remainingPlaces: 0
                ),
                userName: "Giulia Rossi"
            )
        )
        
    }
    
}
