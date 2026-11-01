//
//  StatusCap.swift
//  LineUpApp
//
//  Created by Apprenant174 on 31/10/2026.
//

import Foundation
import SwiftUI

struct StatusCap: View {
    
    let capState : CapsState
    
    let use : CardUse
    var workshopStatus : Availability {

        switch use {
            
        case .workshop(let availability):
            if availability == .full {
                
                return .full
                
            } else {
                
                return .available
                
            }
            
        case .reservation(let status, availability : let availability):
            if availability == .full {
                
                return .full
                
            } else {
                
                return .available
                
            }
            
        }
        
    }

    var body: some View {
        
        HStack(spacing: Styles.gap) {
            
            if capState == .full {
                Text( workshopStatus == .available ? .statusAvailable : .statusFull)
                    .lineupFont(Styles.font)
            }
            
            Styles.icon(workshopStatus)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: Styles.iconSize, maxHeight: Styles.iconSize)
                .padding(.top, capState == .full ? Styles.centerIcon : 0)
            
        }
        .foregroundStyle(workshopStatus == .available ? Styles.foreground : Styles.foregroundMuted)
        .padding(Styles.padding)
        .background {
            
            RoundedRectangle(cornerRadius: Styles.cornerRadius)
                .fill(workshopStatus == .available ? Styles.fill : Styles.fillMuted)
                .strokeBorder(workshopStatus == .available ? Styles.border : Styles.borderMuted, lineWidth: Styles.lineWidth)
                .frame(maxHeight: Styles.capsHeight(capState))
            
        }
        
    }
    
    enum CapsState {
        
        case full
        case reduced
        
    }
    
}

fileprivate struct Styles {
    
    static let font = AppFont.Body.body2
    
    static let fill = AppColor.Capsule.Available.background
    static let fillMuted = AppColor.Capsule.Full.background
    static let cornerRadius = AppToken.Radius.xsmall
    static let padding = AppToken.Padding.smallCard
    static let gap = AppToken.Spacing.s8
    static func capsHeight(_ state : StatusCap.CapsState) -> CGFloat {
        
        switch state {
            
        case .full : return 38
        case .reduced : return 100
            
        }
        
    }
    
    static let border = AppColor.Capsule.Available.border
    static let borderMuted = AppColor.Capsule.Full.border
    static let lineWidth = AppToken.Border.thin
    
    static let foreground = AppColor.Capsule.Available.text
    static let foregroundMuted = AppColor.Capsule.Full.text
    
    
    static func icon(_ status : Availability) -> Image {
        
        switch status {
            
        case .available : return AppImage.Icon.check.image
        case .full : return AppImage.Icon.close.image
            
        }
        
    }
    static let iconSize : CGFloat = 12
    static let centerIcon : CGFloat = 2
}


#Preview {
    StatusCap(capState: .reduced, use: .workshop(.available))
}
