//
//  TicketRow.swift
//  LineUpApp
//
//  Created by Apprenant174 on 02/11/2026.
//

import SwiftUI

// SmallCard d'une réservation avec swipeAction
struct TicketRow: View {
    
    let reservation: Reservation
    var onCancel: (() -> Void)? = nil
    
    var body: some View {
        
        SmallCard(
            cardFormat: .booked,
            use: .reservation(reservation.status, availability: reservation.workshop.availability),
            workshopDate: reservation.workshop.startTime,
            workshopStartTime: reservation.workshop.startTime,
            workshopEndTime: reservation.workshop.endTime,
            workshopCategory: reservation.workshop.categoryName,
            workshopName: reservation.workshop.name
        )
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(Styles.rowInsets)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            
            if let onCancel {
                
                Button {
                    
                    onCancel()
                    
                } label: {
                    
                    Label {
                        Text(.commonCancel)
                    } icon: {
                        Styles.cancelIcon
                    }
                    
                }
                .tint(Styles.cancelColor)
                
            }
            	
        }
        
    }
    
}

fileprivate struct Styles {
    
    static let rowInsets = AppToken.Padding.reservationRow
    
    static let cancelIcon = AppImage.Icon.close.image
    static let cancelColor = AppColor.Button.Primary.background
    
}

#Preview {
    
    List {
        
        TicketRow(
            reservation: Reservation(
                id: 1024,
                status: .validated,
                workshop: Workshop(
                    id: UUID(),
                    name: "La Locandiera",
                    startTime: .now.addingTimeInterval(86_400),
                    endTime: .now.addingTimeInterval(86_400 + 10_800),
                    capacityMax: 30,
                    subscriberNumber: 12,
                    workshopDescription: "",
                    categoryID: UUID(),
                    categoryName: "Théâtre",
                    remainingPlaces: 18
                ),
                userName: "Giulia Rossi"
            ),
            onCancel: {}
        )
        
    }
    .listStyle(.plain)
    
}
