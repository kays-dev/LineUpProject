//
//  SmallCard.swift
//  LineUpApp
//
//  Created by Apprenant174 on 31/10/2026.
//

import Foundation
import SwiftUI

struct SmallCard: View {
    
    let cardFormat : CardState
    let use : CardUse
    
    let workshopDate: Date
    let workshopStartTime: Date
    let workshopEndTime: Date
    
    let workshopCategory: String
    let workshopName: String
    
    var isMuted : Bool {
        Styles.isMuted(use)
    }
    
    var body: some View {
        
        HStack(spacing: Styles.gap) {
            
            // Photo
            Color.clear
                .frame(width: Styles.imageWidth)
                .frame(maxHeight: .infinity)
                .overlay {
                    AppImage.workshopPhoto(for: workshopName)
                        .resizable()
                        .scaledToFill()
                        .overlay {
                            
                            isMuted ? Styles.imageFilter : Styles.imageFilter.opacity(0)
                            
                        }
                }
                .clipShape(.rect(cornerRadius: Styles.imageCornerRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: Styles.imageCornerRadius)
                        .strokeBorder(isMuted ? Styles.imageBorderMuted : Styles.imageBorder, lineWidth: Styles.lineWidth)
                }
            
            // Détail
            VStack(alignment: .leading, spacing: 0) {
                
                HStack(alignment: .top) {
                    WorkshopTime(
                        cardType: .ticketCard(state: cardFormat),
                        isMuted: isMuted,
                        date: workshopDate,
                        startTime: workshopStartTime,
                        endTime: workshopEndTime
                    )
                    
                    if Styles.showStatusIcon(cardFormat) {
                        Spacer()
                        
                        StatusCap(capState: .reduced, use: use)
                    }
                }
                
                Spacer(minLength: 0)
                
                Text(workshopCategory)
                    .lineupFont(Styles.font)
                
                Text(workshopName)
                    .lineupFont(Styles.titleFont)
                    .lineLimit(2)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .padding(Styles.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: Styles.height)
        .foregroundStyle(isMuted ? Styles.foregroundMuted : Styles.foreground)
        .background {
            Ticket(stubWidth: Styles.stubWidth, isMuted: isMuted)
        }
        
    }
    
    enum CardState {
        case standard
        case booked
    }
    
}

fileprivate struct Styles {
    
    
    static let titleFont: AppFont = .Title.title2
    static let font: AppFont = .Body.body2
    
    static let height: CGFloat = 125
    static let padding: CGFloat = 8
    static let gap: CGFloat = 13
    
    static let imageWidth: CGFloat = 65
    static let imageCornerRadius = AppToken.Radius.xsmall
    static let imageFilter: Color = .grayLight.opacity(0.6)
    static let imageBorder = AppColor.Card.Standard.border
    static let imageBorderMuted = AppColor.Card.Muted.border
    static let lineWidth = AppToken.Border.thin
    static let stubWidth: CGFloat = padding + imageWidth + gap / 2
    
    static let foreground: Color = AppColor.Text.primary
    static let foregroundMuted: Color = AppColor.Text.tertiary
    
    static func isMuted(_ status : CardUse) -> Bool {
        
        switch status {
            
        case .workshop(let availability): availability == .full
        case .reservation(let status, availability : _): status != .validated
            
        }
        
    }
    
    static func showStatusIcon(_ state: SmallCard.CardState) -> Bool {
        switch state {
        case .standard: true
        case .booked:   false
        }
    }
    
}


#Preview {
    VStack(spacing: 16) {
        SmallCard(cardFormat: .booked, use: .reservation(.validated, availability: .available),
                  workshopDate: .now, workshopStartTime: .now, workshopEndTime: .now,
                  workshopCategory: "Théâtre", workshopName: "La Locendria")

        SmallCard(cardFormat: .booked, use: .reservation(.cancelled, availability: .available),
                  workshopDate: .now, workshopStartTime: .now, workshopEndTime: .now,
                  workshopCategory: "Théâtre", workshopName: "La Locendria")

        SmallCard(cardFormat: .standard, use: .workshop(.available),
                  workshopDate: .now, workshopStartTime: .now, workshopEndTime: .now,
                  workshopCategory: "Cinéma", workshopName: "Nuovo Cinema Paradiso")
    }
    .padding()
}
