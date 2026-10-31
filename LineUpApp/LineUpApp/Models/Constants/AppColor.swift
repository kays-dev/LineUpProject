//
//  AppColor.swift
//  LineUpApp
//
//  Created by Apprenant174 on 26/10/2026.
//

import Foundation
import SwiftUI
 
enum AppColor {
    
    enum Text {
        static let primary: Color = .ink
        static let secondary: Color = .mintPrimary
        static let tertiary: Color = .inkMuted
    }
    
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
        static let ghostDangerTextPressed: Color = .dangerDark
 
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

        enum Text {
            static let text: Color = .ink
            static let pressed: Color = .redPrimary
            static let disabled: Color = .grayDark
        }

        enum Link {
            static let text: Color = .ink
            static let pressed: Color = .redPrimary
            static let disabled: Color = .grayDark
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
        static let separator: Color = .grayPrimary
 
        enum Icon {
            static let background: Color = .tealLight
            static let icon: Color = .ink
            static let border: Color = .ink
        }
 
        enum Checkbox {
            static let background: Color = .greenPrimary
            static let border: Color = .ink
            static let icon: Color = .ink
            static let uncheckedBackground: Color = .whitePrimary
        }
 
        enum Radio {
            static let background: Color = .greenPrimary
            static let border: Color = .ink
            static let innerCircle: Color = .ink
            static let unselectedBackground: Color = .whitePrimary
        }
 
        enum Toggle {
            static let background: Color = .greenPrimary
            static let border: Color = .ink
            static let knob: Color = .whitePrimary
            static let knobBorder: Color = .ink
            static let offBackground: Color = .whitePrimary
            static let offKnob: Color = .ink
        }

        enum Disabled {
            static let selectedBackground: Color = .greenLight
            static let border: Color = .grayDark
            static let content: Color = .grayDark
        }
    }
 
    // --- ModalFilters --- //
 
    enum ModalFilters {
 
        static let textPrimary: Color = .ink
        static let textSecondary: Color = .mintPrimary
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

    // --- AvatarPicker --- //

    enum AvatarPicker {
        static let previewBackground: Color = .whitePrimary
        static let selectedRing: Color = .redPrimary
        static let photoBorder: Color = .ink
        static let selectedName: Color = .redPrimary
        static let name: Color = .ink
    }

    // --- Picker --- //

    enum Picker {
        static let background: Color = .whitePrimary
        static let border: Color = .ink
        static let selectedBackground: Color = .greenPrimary
        static let text: Color = .ink
        static let nearText: Color = .inkMuted
        static let farText: Color = .grayDark
    }
}
 
