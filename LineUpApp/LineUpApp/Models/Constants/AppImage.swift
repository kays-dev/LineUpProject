//
//  AppImage.swift
//  LineUpApp
//
//  Created by Apprenant174 on 26/10/2026.
//

import Foundation
import SwiftUI

enum AppImage {

    static let confetti = Image("confetti")
    static let confettiBottomLeft = Image("confetti-bottom-left")

    // Avatars du profil
    enum Avatar: String, CaseIterable {
        case pinocchio = "avatar-pinocchio"
        case arlecchino = "avatar-arlecchino"
        case pulcinella = "avatar-pulcinella"
        case leonardoDaVinci = "avatar-leonardo-da-vinci"
        case donCorleone = "avatar-don-corleone"
        case colombina = "avatar-colombina"
        case monaLisa = "avatar-mona-lisa"
        case fountainStar = "avatar-fountain-star"
        case romanVespista = "avatar-roman-vespista"
        case laBefana = "avatar-la-befana"
        case lionOfSaintMark = "avatar-lion-of-saint-mark"
        case venetianMaskBauta = "avatar-venetian-mask-bauta"

        var image: Image {
            Image(rawValue)
        }
    }

    // Catégories d'ateliers : icônes et motifs
    enum Category: String {
        case theater = "Théâtre"
        case movie = "Cinéma"
        case kids = "Jeune public"
        case musicDance = "Musique & danse"
        case photography = "Photo"
        case culture = "Culture & patrimoine"

        var imageName: String {
            switch self {
            case .theater:
                "theater"
            case .movie:
                "movie"
            case .kids:
                "kids"
            case .musicDance:
                "music-dance"
            case .photography:
                "photography"
            case .culture:
                "culture"
            }
        }

        var icon: Image {
            Image(imageName)
        }

        var smallIcon: Image {
            Image(imageName + "-reduced")
        }

        var pastIcon: Image {
            Image(imageName + "-grayscaled")
        }

        var pattern: Image {
            switch self {
            case .theater:
                Image("pattern-theater")
            case .movie:
                Image("pattern-movie-grayscaled")
            case .kids:
                Image("pattern-kids")
            case .musicDance, .photography, .culture:
                Image("pattern-arts")
            }
        }
    }

    // Icônes système (SF Symbols)
    enum Icon: String {
        case back = "chevron.left"
        case forward = "chevron.right"
        case expand = "chevron.down"
        case close = "xmark"
        case check = "checkmark"
        case checkCircle = "checkmark.circle"
        case search = "magnifyingglass"
        case share = "square.and.arrow.up"
        case settings = "gearshape"
        case sort = "slider.horizontal.3"
        case waiting = "ellipsis"
        case clock = "clock"
        case calendar = "calendar"
        case sparkles = "sparkles"
        case trash = "trash"
        case filter = "slider.horizontal.2.square"

        var image: Image {
            Image(systemName: rawValue)
        }
    }

    // Illustrations des popups
    enum Popup: String {
        case warning = "popup-warning"
        case validation = "popup-validation"
        case danger = "popup-danger"

        var image: Image {
            Image(rawValue)
        }
    }

    // Drapeaux du choix de la langue
    enum Flag: String, CaseIterable {
        case french = "flag-france"
        case italian = "flag-italy"

        var image: Image {
            Image(rawValue)
        }
    }

    // Photo d'un atelier à partir de son nom
    static func workshopPhoto(for name: String) -> Image {
        switch name {
        case "Éternel Tintoret":
            Image("workshop-eternel-tintoret")
        case "L'atelier des enfants":
            Image("workshop-atelier-des-enfants")
        case "Ville Lumière ou Città Eterna":
            Image("workshop-ville-lumiere-citta-eterna")
        case "La dolce vita":
            Image("workshop-la-dolce-vita")
        case "La Locandiera":
            Image("workshop-la-locandiera")
        case "L'art du faux parfait":
            Image("workshop-l-art-du-faux-parfait")
        case "Le Voleur de bicyclette":
            Image("workshop-le-voleur-de-bicyclette")
        case "Tutta Vita Tour - Olly":
            Image("workshop-tutta-vita-tour-olly")
        case "Rome Ville ouverte":
            Image("workshop-rome-ville-ouverte")
        case "Nei letti degli altri Tour - Mahmood":
            Image("workshop-nei-letti-degli-altri-mahmood")
        default:
            Image("workshop")
        }
    }
}
