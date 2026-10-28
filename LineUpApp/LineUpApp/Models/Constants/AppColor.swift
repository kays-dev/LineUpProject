//
//  AppColor.swift
//  LineUpApp
//
//  Created by Apprenant174 on 26/10/2026.
//

import Foundation
import SwiftUI
 
enum AppColor {
    
    // --- cards -- //
 
    enum Card {
 
        // Carte normale (workshop, réservation, réservation sans date connue).
        enum Standard {
            static let background: Color = .whitePrimary
            static let timeBackground: Color = .ink
            static let border: Color = .ink
        }
 
        // Carte estompée (workshop passé, réservation complète, réservation sans date connue).
        enum Muted {
            static let background: Color = .grayLight
            static let timeBackground: Color = .inkMuted
            static let border: Color = .inkMuted
        }
 
        // Workshop en cours.
        enum Ongoing {
            static let background: Color = .whitePrimary
            static let timeBackground: Color = .greenPrimary
            static let border: Color = .ink
        }
 
        // Réservation annulée.
        enum Cancelled {
            static let background: Color = .mintPrimary
            static let timeBackground: Color = .ink
            static let border: Color = .ink
        }
 
        // Réservation annulée et complète.
        enum CancelledFull {
            static let background: Color = .mintPrimary
            static let timeBackground: Color = .inkMuted
            static let border: Color = .inkMuted
        }
    }
 
    // --- Buttons -- //
    
    enum Button {
 
        // Bordure secondaire affichée quand un bouton a le focus.
        static let focusRing: Color = .redPrimary
 
        // Bouton danger sans fond (texte seul).
        static let ghostDangerText: Color = .dangerSaturated
 
        enum Primary {
            static let background: Color = .redPrimary
            static let text: Color = .mintPrimary
            static let border: Color = .ink
        }
 
        enum Secondary {
            static let background: Color = .whitePrimary
            static let text: Color = .redPrimary
            static let border: Color = .redPrimary
        }
 
        enum Pressed {
            static let background: Color = .ink
            static let text: Color = .mintPrimary
            static let border: Color = .ink
        }
 
        enum Disabled {
            static let background: Color = .grayLight
            static let text: Color = .grayDark
            static let border: Color = .grayDark
        }
 
        enum Confirmed {
            static let background: Color = .greenPrimary
            static let text: Color = .ink
            static let border: Color = .ink
        }
 
        enum Danger {
            static let background: Color = .danger
            static let text: Color = .ink
            static let border: Color = .ink
        }
 
        enum Warning {
            static let background: Color = .warning
            static let text: Color = .ink
            static let border: Color = .ink
        }
 
        enum Success {
            static let background: Color = .validation
            static let text: Color = .ink
            static let border: Color = .ink
        }
    }

    // --- Badges status --- //
 
    enum BadgeStatus {
 
        enum Available {
            static let background: Color = .greenLight
            static let text: Color = .ink
            static let border: Color = .ink
        }
 
        enum Unavailable {
            static let background: Color = .redLight
            static let text: Color = .ink
            static let border: Color = .ink
        }
 
        enum Full {
            static let background: Color = .grayDark
            static let text: Color = .inkMuted
            static let border: Color = .inkMuted
        }
    }
 
    // --- Capsules --- //
 
    enum Capsule {
 
        enum Available {
            static let background: Color = .greenLight
            static let text: Color = .validationDark
            static let border: Color = .validationDark
        }
 
        enum Unavailable {
            static let background: Color = .grayDark
            static let text: Color = .inkMuted
            static let border: Color = .inkMuted
        }
    }
 
    // --- SettingRow --- //
 
    enum SettingRow {
 
        static let background: Color = .whitePrimary
        static let title: Color = .ink
        static let descriptionAndChevron: Color = .inkMuted
 
        enum Icon {
            static let background: Color = .tealLight
            static let icon: Color = .ink
            static let border: Color = .ink
        }
 
        enum Checkbox {
            static let background: Color = .greenPrimary
            static let border: Color = .ink
            static let icon: Color = .ink
        }
 
        enum Radio {
            static let background: Color = .greenPrimary
            static let border: Color = .ink
            static let innerCircle: Color = .ink
        }
 
        enum Toggle {
            static let background: Color = .greenPrimary
            static let border: Color = .ink
            static let knob: Color = .whitePrimary
            static let knobBorder: Color = .ink
        }
    }
 
    // --- ModalFilters --- //
 
    enum ModalFilters {
 
        static let text: Color = .mintPrimary
        static let titleIcon: Color = .tealPrimary
 
        enum Selected {
            static let background: Color = .tealDark
            static let border: Color = .tealPrimary
        }
 
        enum Unselected {
            static let background: Color = .mintPrimary
            static let border: Color = .tealLight
        }
 
        enum Delete {
            static let text: Color = .mintPrimary
            static let icon: Color = .redPrimary
        }
    }
 
    // --- Tabbar --- //
 
    enum TabBar {
        static let background: Color = .ink
        static let label: Color = .tealLight
    }
}
 
