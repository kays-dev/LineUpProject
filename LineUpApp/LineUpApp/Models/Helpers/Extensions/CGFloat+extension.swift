//
//  CGFloat+extension.swift
//  LineUpApp
//
//  Created by Apprenant174 on 29/10/2026.
//

import Foundation
import SwiftUI

// MARK: Transpose un CGFloat en EdgeInsets
extension CGFloat {
    
    var insets: EdgeInsets {
        
        .init(top: self, leading: self, bottom: self, trailing: self)
        
    }
    
}
