//
//  AppFont.swift
//  LineUpApp
//
//  Created by Apprenant174 on 26/10/2026.
//

import UIKit
import SwiftUI

struct AppFont {
    
    let name: FontName
    let size: CGFloat
    let lineHeight: CGFloat?
    let uppercase: Bool
    let relativeTo: Font.TextStyle
    
    let letterSpacing: CGFloat        // % de l'espacement des caractères de Figma, pour convertion
    
    var font: Font {
        
        .custom(name.rawValue, size: size, relativeTo: relativeTo)
        
    }
    
    var lineSpacing: CGFloat {
        
        guard let lineHeight, let uiFont = UIFont(name: name.rawValue, size: size) else {
            return 0
        }
        
        return max(0, lineHeight - uiFont.lineHeight)
    }
    
}

// MARK: Noms des polices importées
extension AppFont {
    
    enum FontName: String, CaseIterable {
        
        case archivoMedium  = "Archivo-Medium"
        case archivoBold    = "Archivo-Bold"
        case archivoBlack   = "Archivo-Black"
        case barlowRegular  = "Barlow-Regular"
        case barlowItalic   = "Barlow-Italic"
        case barlowMedium   = "Barlow-Medium"
        case barlowSemiBold = "Barlow-SemiBold"
        case barlowBold     = "Barlow-Bold"
        
    }
    
}

// MARK: Liste des styles de texte utilisés dans l'app
extension AppFont {
    
    // MARK: - Titres
    enum Title {
        
        static let heading = AppFont(name: .archivoBold,   size: 34, lineHeight: 40, uppercase: true,  relativeTo: .largeTitle, letterSpacing: -0.68)
        static let title = AppFont(name: .archivoBold,   size: 24, lineHeight: 30,     uppercase: false, relativeTo: .title, letterSpacing: 0)
        static let title2 = AppFont(name: .archivoMedium, size: 20, lineHeight: 26,     uppercase: false, relativeTo: .title2, letterSpacing: 0)
        
    }
    
    // MARK: Corps
    enum Body {
        
        static let body = AppFont(name: .barlowRegular,  size: 16, lineHeight: 24, uppercase: false, relativeTo: .body,  letterSpacing: 0)
        static let body2 = AppFont(name: .barlowRegular,  size: 14, lineHeight: 20, uppercase: false, relativeTo: .subheadline,  letterSpacing: 0)
        static let section = AppFont(name: .barlowSemiBold, size: 12, lineHeight: 16, uppercase: true,  relativeTo: .caption,  letterSpacing: 6)
        static let caption = AppFont(name: .barlowRegular,  size: 12, lineHeight: 16, uppercase: false, relativeTo: .caption,  letterSpacing: 0)
        static let link = AppFont(name: .barlowSemiBold, size: 16, lineHeight: 24, uppercase: false, relativeTo: .body,  letterSpacing: 0)
        
    }
    
    // MARK: Labels de boutons, capsules, etc
    enum Label {
        
        static let label = AppFont(name: .archivoBlack, size: 13, lineHeight: 16, uppercase: true, relativeTo: .footnote, letterSpacing: 5)
        
    }
    
    // MARK: Textes de la Tabbar
    enum Navigation {
        
        static let tabBarLabel = AppFont(name: .barlowSemiBold, size: 11, lineHeight: nil, uppercase: false, relativeTo: .caption2, letterSpacing: 0)
        
    }
    
    // MARK: Inputs
    enum Input {
        
        static let fieldText = AppFont(name: .barlowMedium,   size: 14, lineHeight: 16, uppercase: false, relativeTo: .subheadline,  letterSpacing: 0)
        static let selectFieldSelected = AppFont(name: .barlowBold,     size: 14, lineHeight: 16, uppercase: false, relativeTo: .subheadline,  letterSpacing: 0)
        static let stepper = AppFont(name: .barlowMedium,   size: 14, lineHeight: 16, uppercase: true,  relativeTo: .subheadline,  letterSpacing: 0)
        
    }
    
    // MARK: Styles de texte de composants spécifiques
    enum Component {
        
        static let progressBar = AppFont(name: .barlowMedium,   size: 12, lineHeight: 16, uppercase: false, relativeTo: .caption,  letterSpacing: 0)
        
    }
    
}
