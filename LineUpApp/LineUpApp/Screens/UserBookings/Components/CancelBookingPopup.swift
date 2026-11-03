//
//  CancelBookingPopup.swift
//  LineUpApp
//
//  Created by Apprenant174 on 02/11/2026.
//

import SwiftUI

struct CancelBookingPopup: View {
    
    let reservation: Reservation
    let onConfirm: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    private var isWaitlist: Bool {
        reservation.status == .pending
    }
    
    var body: some View {
        
        StatusPopup(
            type: .warning,
            title: String(localized: isWaitlist ? .cancelWaitlistTitle : .cancelBookingTitle),
            message: String(localized: isWaitlist
                            ? .cancelWaitlistMessage(reservation.code, reservation.workshop.name)
                            : .cancelBookingMessage(reservation.code, reservation.workshop.name)),
            buttonTitle: String(localized: .cancelConfirm)
        ) {
            onConfirm()
            dismiss()
        }
        .overlay(alignment: .topTrailing) {
            
            AppButton(title: "common.close", icon: Styles.closeIcon, type: .iconFilled, shape: .radius16) {
                dismiss()
            }
            .padding(Styles.closePadding)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .presentationBackground(Styles.background)
        
    }
    
}

fileprivate struct Styles {
    
    static let background = AppColor.Screen.background
    static let closeIcon = AppImage.Icon.close.image
    static let closePadding = AppToken.Spacing.s16
    
}

#Preview {
    
    CancelBookingPopup(
        reservation: Reservation(
            id: 1024,
            status: .validated,
            workshop: Workshop(
                id: UUID(),
                name: "La Locandiera",
                startTime: .now,
                endTime: .now.addingTimeInterval(10_800),
                capacityMax: 30,
                subscriberNumber: 12,
                workshopDescription: "",
                categoryID: UUID(),
                categoryName: "Théâtre",
                remainingPlaces: 18
            ),
            userName: "Giulia Rossi"
        ),
        onConfirm: {}
    )
    
}
