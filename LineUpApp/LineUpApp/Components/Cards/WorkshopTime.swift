//
//  WorkshopTime.swift
//  LineUpApp
//
//  Created by Apprenant174 on 31/10/2026.
//

import Foundation
import SwiftUI

struct WorkshopTime : View {
    
    let cardType : CardType
    let isMuted : Bool
    
    let date : Date
    let startTime : Date
    let endTime : Date
    
    private var styles : Styles {
        Styles(for: cardType, isMuted: isMuted)
    }
    
    var body: some View {
        
            HStack(spacing: styles.gap){
                
                if styles.showsDate {
                    
                    HStack(spacing: Styles.iconGap){
                        
                        Styles.dateIcon
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: Styles.iconSize)
                        
                        Text(date, format: Styles.dateFormat)
                            .lineupFont(styles.font)
                        
                    }
                    
                    if styles.fillsWidth {
                        Spacer()
                    }
                    
                }
                
                HStack(spacing: Styles.iconGap){
                    
                    Styles.timeIcon
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: Styles.iconSize)
                    
                    Text("""
 \(Text(startTime, format: Styles.timeFormat)) — \(Text(endTime, format: Styles.timeFormat))
 """)
                    .lineupFont(styles.font)
                    
                }
                
            }
            .padding(Styles.padding)
            .frame(height: Styles.height)
            .foregroundStyle(styles.foreground)
            .background{
                RoundedRectangle(cornerRadius: Styles.cornerRadius)
                    .fill(styles.fill)
                    .strokeBorder(isMuted ? Styles.borderMuted : Styles.border, lineWidth: Styles.lineWidth)
            }
        
    }
    
    enum CardType {
        
        case bigCard(state : BigCard.CardState)
        case ticketCard(state : SmallCard.CardState)
        
    }
}

fileprivate struct Styles {
    
    // Styles variables
    let font : AppFont
    
    let fill : Color
    let gap : CGFloat
    
    let foreground : Color
    
    let showsDate: Bool
    let fillsWidth: Bool
    
    // Styles fixes
    static let cornerRadius = AppToken.Radius.xsmall
    static let padding = AppToken.Padding.smallBox
    static let height : CGFloat =  34
    
    static let border = AppColor.Card.Standard.border
    static let borderMuted = AppColor.Card.Muted.border
    static let lineWidth = AppToken.Border.thin
    
    // Icônes
    static let timeIcon = AppImage.Icon.clock.image
    static let dateIcon = AppImage.Icon.calendar.image
    
    static let iconSize : CGFloat = 16
    
    static let iconGap = AppToken.Spacing.s4
    
    // Date
    static let timeFormat: Date.FormatStyle = .dateTime
        .hour(.twoDigits(amPM: .omitted))
        .minute(.twoDigits)
    
    static let dateFormat: Date.FormatStyle = .dateTime.weekday(.abbreviated).day()
    
    init(for type : WorkshopTime.CardType, isMuted : Bool) {
        
        switch type {
            
        case .bigCard(state: .standard), .bigCard(state: .compact):
            
            font = AppFont.Label.label
            
            fill = isMuted ? AppColor.Card.Muted.timeBackground :  AppColor.Card.Standard.timeBackground
            gap = 0
            
            foreground = isMuted ? .grayLight : AppColor.Text.secondary
            
            showsDate = true
            fillsWidth = true
            
        case .bigCard(state: .ongoing):
            
            font = AppFont.Label.label
            
            fill = isMuted ? .grayDark :  AppColor.Card.Ongoing.timeBackground
            gap = 0
            
            foreground = isMuted ? AppColor.Text.tertiary : AppColor.Text.primary
            
            showsDate = false
            fillsWidth = false
            
        case .ticketCard(state: .standard), .ticketCard(state: .booked):
            
            font = AppFont.Body.caption
            
            fill = isMuted ? AppColor.Card.Muted.timeBackground :  AppColor.Card.Standard.timeBackground
            gap = AppToken.Spacing.s16
            
            foreground = isMuted ? .grayLight : AppColor.Text.secondary
            
            showsDate = true
            fillsWidth = false
            
        }
        
    }
    
}


#Preview {
    WorkshopTime(cardType: .bigCard(state: .standard), isMuted: false, date: .now, startTime: .now, endTime: .now)
    
    WorkshopTime(cardType: .bigCard(state: .ongoing), isMuted: false, date: .now, startTime: .now, endTime: .now)
    
    WorkshopTime(cardType: .bigCard(state: .compact), isMuted: false, date: .now, startTime: .now, endTime: .now)
    
    WorkshopTime(cardType: .ticketCard(state: .booked), isMuted: false, date: .now, startTime: .now, endTime: .now)
    
    WorkshopTime(cardType: .ticketCard(state: .standard), isMuted: false, date: .now, startTime: .now, endTime: .now)
}
