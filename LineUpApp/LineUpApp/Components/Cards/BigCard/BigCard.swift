//
//  BigCards.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

struct BigCard: View {
    
    let cardFormat : CardState
    let use : CardUse
    
    let workshopDate : Date
    let workshopStartTime : Date
    let workshopEndTime : Date
    
    let workshopCategory : String
    let workshopIcon : AppImage.Category
    let workshopName : String
    
    let remainingPlaces : Int
    let capacityMax : Int
    
    var isMuted : Bool {
        Styles.isMuted(use)
    }
    
    var body: some View {
        
        VStack(alignment: Styles.centerTime(cardFormat) ? .center : .leading, spacing: Styles.gap){
            
                WorkshopTime(cardType: .bigCard(state: cardFormat), isMuted: isMuted, date: workshopDate, startTime: workshopStartTime, endTime: workshopEndTime)
            
            if Styles.showDetails(cardFormat) {
                
                VStack(alignment: Styles.centerTime(cardFormat) ? .center : .leading) {
                    
                    Text("\(workshopCategory)")
                        .lineupFont(Styles.font)
                    
                    Text("\(workshopName)")
                        .lineupFont(Styles.titleFont)
                    
                }
                .frame(width: .infinity, alignment: Styles.centerTime(cardFormat) ? .center : .leading)
                
            }
            
            Color.white
                .frame(width: .infinity)
                .aspectRatio(16/9, contentMode: .fit)
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
                        .strokeBorder(isMuted ? Styles.borderMuted : Styles.border, lineWidth: Styles.lineWidth)
                }
            
            if Styles.showAvailibility(cardFormat) {
                
                HStack {
                    
                    StatusCap(capState: .full, use: use)
                    
                    Spacer()
                    
                    Text("""
                     \(Text("\(remainingPlaces)")) places restantes / \(Text("\(capacityMax)"))
                     """)
                    .lineupFont(Styles.font)
                    
                }
                
            }
            
        } //ribbons en bg
        .foregroundStyle(isMuted ? Styles.foregroundMuted : Styles.foreground)
        .padding(Styles.padding)
        .frame(width: .infinity)
        .background {
            
            ZStack {
                switch cardFormat {
                    
                case .standard:
                    
                    CardRibbon(categoryIcon: workshopIcon, isMuted: isMuted)
                        .rotationEffect(.degrees(-9.32))
                        .offset(x: 33, y: -40)
                    CardRibbon(categoryIcon: workshopIcon, isMuted: isMuted)
                        .rotationEffect(.degrees(5))
                        .offset(x: 10, y: 30)
                    CardRibbon(categoryIcon: workshopIcon, isMuted: isMuted)
                        .rotationEffect(.degrees(-8.15))
                        .offset(x: 69, y: 85)
                    
                case .ongoing:
                    
                    CardRibbon(categoryIcon: workshopIcon, isMuted: isMuted)
                        .rotationEffect(.degrees(-9.32))
                        .offset(x: 33, y: 10)
                    CardRibbon(categoryIcon: workshopIcon, isMuted: isMuted)
                        .rotationEffect(.degrees(3.26))
                        .offset(x: 10, y: 60)
                    CardRibbon(categoryIcon: workshopIcon, isMuted: isMuted)
                        .rotationEffect(.degrees(-8.15))
                        .offset(x: 69, y: 110)
                    
                case .compact:
                    CardRibbon(categoryIcon: workshopIcon, isMuted: isMuted)
                        .rotationEffect(.degrees(-9.32))
                        .offset(x: 33, y: -55)
                    CardRibbon(categoryIcon: workshopIcon, isMuted: isMuted)
                        .rotationEffect(.degrees(3.26))
                        .offset(x: 10, y: 5)
                    CardRibbon(categoryIcon: workshopIcon, isMuted: isMuted)
                        .rotationEffect(.degrees(-8.15))
                        .offset(x: 69, y: 50)
                }
                

            }
            
        }
        .background(isMuted ? Styles.fillMuted : Styles.fill)
        .clipShape(.rect(cornerRadius: Styles.cornerRadius))
        .overlay {
            
            RoundedRectangle(cornerRadius: Styles.cornerRadius)
                .strokeBorder(isMuted ? Styles.borderMuted : Styles.border, lineWidth: Styles.lineWidth)
            
        }
    }
    
    enum CardState {
        case standard
        case ongoing
        case compact
    }
    
}

fileprivate struct Styles {
    
    // Styles variables
    static let titleFont : AppFont = .Title.title2
    static let font : AppFont = .Body.body2
    
    static let fill : Color = AppColor.Card.Standard.background
    static let fillMuted : Color = AppColor.Card.Muted.background
    static let gap : CGFloat = AppToken.Spacing.s28
    static let cornerRadius = AppToken.Radius.big
    static let padding = AppToken.Padding.largeCard
    
    static let foreground : Color = AppColor.Text.primary
    static let foregroundMuted : Color = AppColor.Text.tertiary
    
    static let border = AppColor.Card.Standard.border
    static let borderMuted = AppColor.Card.Muted.border
    static let lineWidth = AppToken.Border.thin
    
    // Image
    static let imageFilter : Color = .grayLight.opacity(0.6)
    static let imageCornerRadius = AppToken.Radius.small
    
    // Affichage conditionnel
    static let showAvailibility = true
    
    static func isMuted(_ status : CardUse) -> Bool {
        
        switch status {
            
        case .workshop(let availability): availability == .full
        case .reservation(let status, availability : let availability): status != .validated
            
        }
        
    }
    
    static func showAvailibility(_ state : BigCard.CardState) -> Bool {
        
        switch state {
            
        case .compact, .standard : return true
        case .ongoing : return false
            
        }
        
    }
    
    static func showDetails(_ state : BigCard.CardState) -> Bool {
        
        switch state {
            
        case .ongoing, .standard : return true
        case .compact : return false
            
        }
        
    }
    
    static func centerTime(_ state : BigCard.CardState) -> Bool {
        
        switch state {
            
        case .compact, .standard : return false
        case .ongoing : return true
            
        }
        
    }
    
}


#Preview {
    ScrollView{
        
        VStack{
            BigCard(cardFormat: .standard, use: .workshop(.available), workshopDate: .now, workshopStartTime: .now, workshopEndTime: .now, workshopCategory: "Théâtre", workshopIcon: .theater, workshopName: "La Locendria", remainingPlaces: 5, capacityMax: 30)
        }
        .padding()
        
        VStack{
            BigCard(cardFormat: .compact, use: .workshop(.available), workshopDate: .now, workshopStartTime: .now, workshopEndTime: .now, workshopCategory: "Théâtre", workshopIcon: .theater, workshopName: "La Locendria", remainingPlaces: 5, capacityMax: 30)
        }
        .padding()
        
        VStack{
            BigCard(cardFormat: .ongoing, use: .workshop(.available), workshopDate: .now, workshopStartTime: .now, workshopEndTime: .now, workshopCategory: "Théâtre", workshopIcon: .theater, workshopName: "La Locendria", remainingPlaces: 5, capacityMax: 30)
        }
        .padding()
    }
}
