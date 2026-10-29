//
//  AppToken.swift
//  LineUpApp
//
//  Created by Apprenant174 on 26/10/2026.
//

import Foundation
import SwiftUI

enum AppToken {
    
    // MARK: - Scale
    enum Scale {
        
        static let primitive0: CGFloat = 0
        static let primitive1: CGFloat = 1
        static let primitive2: CGFloat = 2
        static let primitive4: CGFloat = 4
        static let primitive8: CGFloat = 8
        static let primitive12: CGFloat = 12
        static let primitive16: CGFloat = 16
        static let primitive20: CGFloat = 20
        static let primitive24: CGFloat = 24
        static let primitive28: CGFloat = 28
        static let primitive32: CGFloat = 32
        static let primitive36: CGFloat = 36
        static let primitive40: CGFloat = 40
        static let primitive44: CGFloat = 44
        static let primitive48: CGFloat = 48
        static let primitive52: CGFloat = 52
        static let primitiveFull: CGFloat = 999
        
    }
    
}
    
extension AppToken {
    
    // MARK: Spacing
    enum Spacing {
        
        static let none = Scale.primitive0
        static let s4 = Scale.primitive4
        static let s8 = Scale.primitive8
        static let s12 = Scale.primitive12
        static let s16 = Scale.primitive16
        static let s20 = Scale.primitive20
        static let s24 = Scale.primitive24
        static let s28 = Scale.primitive28
        static let s32 = Scale.primitive32
        
    }

    // MARK: Radii
    enum Radius {
        
        static let none = Scale.primitive0
        static let xsmall = Scale.primitive8
        static let small = Scale.primitive16
        static let big = Scale.primitive24
        static let full = Scale.primitiveFull
        
    }

    // MARK: Border
    enum Border {
        
        static let none = Scale.primitive0
        static let thin = Scale.primitive1
        static let medium = Scale.primitive2
        static let thick = Scale.primitive4
        
    }

    // MARK: Padding
    enum Padding {
        
        static let none = Spacing.none

        // Écran complet
        static let screen = Spacing.s20
        static let headerBottom = Spacing.s28
        static let scrollViewBottom = Spacing.s32

        // Conteneurs
        static let smallBox = EdgeInsets(vertical: Spacing.s8, horizontal: Spacing.s16)
        static let smallCard = Spacing.s8.insets
        static let largeCard = EdgeInsets(vertical: Spacing.s24, horizontal: Spacing.s16)

        // Composants
        static let field = Spacing.s16.insets
        static let button = EdgeInsets(vertical: Spacing.s16, horizontal: Spacing.s24)
        static let buttonText = EdgeInsets(vertical: Spacing.none, horizontal: Spacing.s8)
        static let settingsRow = EdgeInsets(vertical: Spacing.s12, horizontal: Spacing.s16)
        static let caps = Spacing.s8
        static let icon = Spacing.s8
        static let toggleTrack = Spacing.s4

        // Tab bar (valeurs natives Apple, hors primitives)
        static let tabBar = EdgeInsets(top: 16, leading: 25, bottom: 25, trailing: 25)
        
    }
    
}
