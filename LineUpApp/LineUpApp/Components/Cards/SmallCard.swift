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
    let use : Use
    
    var isMuted : Bool {
        Styles.isMuted(use)
    }
    
    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
    }
    
    enum CardState {
        case standard
        case booked
    }
    
    enum Use {
        case workshop(Availability)
        case reservation(ReservationStatus, availability: Availability)
    }
    
}

fileprivate struct Styles {
    
    
    
    static func isMuted(_ status : SmallCard.Use) -> Bool {
        
        switch status {
            
        case .workshop(let availability): availability == .full
        case .reservation(let status, availability : let availability): status != .validated
            
        }
        
    }
    
}


#Preview {
    SmallCard(cardFormat: .standard, use: .workshop(.available))
}
