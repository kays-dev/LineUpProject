//
//  AppLanguage.swift
//  LineUpApp
//
//  Created by Apprenant174 on 02/11/2026.
//

import Foundation

enum AppLanguage: String, CaseIterable {
    case french = "fr"
    case italian = "it"
    case english = "en"

    var name: String {
        switch self {
        case .french:
            "Français"
        case .italian:
            "Italiano"
        case .english:
            "English"
        }
    }
}
