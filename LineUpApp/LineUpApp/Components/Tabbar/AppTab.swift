//
//  AppTab.swift
//  LineUpApp
//
//  Created by Apprenant174 on 01/11/2026.
//

import SwiftUI

enum LineUpTab: Int, CaseIterable, Identifiable {
    
    case affiche
    case agenda
    case aparte

    var id: Int {
        rawValue
    }

    // Clé Localizable (FR : Affiche / Agenda / Aparté — EN : StageUp / NextUp / CloseUp — IT : Cartellone / Palco / Camerino).
    // L'onglet Aparté n'affiche pas de libellé (c'est l'avatar), seulement pour le VoiceOver.
    var label: LocalizedStringKey {
        
        switch self {
            
        case .affiche:
            "Affiche"
        case .agenda:
            "Agenda"
        case .aparte:
            "Aparté"
            
        }
    }

    // Icône Phosphor dans la bulle (Filled)
    var activeIcon: Image {
        switch self {
        case .affiche:
            AppImage.InterfaceIcon.calendarCheckFill.image
        case .agenda:
            AppImage.InterfaceIcon.ticketFill.image
        case .aparte:
            AppImage.Avatar.colombina.image
        }
    }

    // Icône Phosphor au repos (Duotone)
    var inactiveIcon: Image {
        switch self {
        case .affiche:
            AppImage.InterfaceIcon.calendarCheckDuotone.image
        case .agenda:
            AppImage.InterfaceIcon.ticketDuotone.image
        case .aparte:
            AppImage.Avatar.colombina.image
        }
    }

    // Écrans de niveau 1
    @ViewBuilder
    func rootView(viewModel: WorkshopFiltersViewModel) -> some View {
        switch self {
        case .affiche:
            FestivalPlanningScreen(viewModel: viewModel)

        case .agenda:
            UserBookingsScreen()

        case .aparte:
            ProfileScreen()
        }
    }
    
}
