//
//  APIError.swift
//  LineUpApp
//
//  Created by Apprenant174 on 30/10/2026.
//

import Foundation

enum APIError: Error {
    
    // L'URL n'a pas pu être construite (path ou query params invalides)
    case invalidURL
    
    // Le serveur n'a pas renvoyé de réponse HTTP exploitable
    case invalidResponse
    
    // Statut HTTP hors 200..<300 (401, 404, 409…)
    case badStatus(Int)
    
    // Le JSON ne correspond pas au DTO attendu
    case decoding(Error)
    
    // La route login n'a pas renvoyé de token lisible
    case invalidToken
    
}
