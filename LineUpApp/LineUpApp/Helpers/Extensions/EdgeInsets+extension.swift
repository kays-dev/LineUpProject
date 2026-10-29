//
//  EdgeInsets+extension.swift
//  LineUpApp
//
//  Created by Apprenant174 on 29/10/2026.
//

import Foundation
import SwiftUI

// MARK: Custom un EdgeInsets en donnant une 2 valeurs au lieu de 4. Évite de créer 2 variables pour les sets de padding horizontal/padding vertical.
extension EdgeInsets {
    
    init(vertical: CGFloat, horizontal: CGFloat) {
        
        self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
        
    }
    
}
