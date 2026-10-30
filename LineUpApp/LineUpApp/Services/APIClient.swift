//
//  APIClient.swift
//  LineUpApp
//
//  Created by Apprenant174 on 26/10/2026.
//

import Foundation

enum HTTPMethod: String {
    
    case get
    case post
    case put
    case patch
    case delete
    
    var value: String {
        
        switch self {
            
        case .get : "GET"
        case .post : "POST"
        case .put : "PUT"
        case .patch : "PATCH"
        case .delete : "DELETE"
            
        }
        
    }
    
}

final class APIClient {
    
    private let baseURL: URL
    private let keychain: KeychainService
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(baseURL: URL, keychain: KeychainService, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.keychain = keychain
        self.session = session

        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: -- Fonction perform() -- Envoie la requête, vérifie le statut HTTP, renvoie les données brutes
    func perform(path: String, method: HTTPMethod = .get, query: [String: String?] = [:], body: (any Encodable)? = nil) async throws -> Data {
        
        // Vérifie la route de base sans query params (ex: http://localhost:8080/appios/workshops) et la transforme en URL
        guard var components = URLComponents( url: baseURL.appending(path: path), resolvingAgainstBaseURL: false) else {
            
            throw APIError.invalidURL
            
        }
        // ---

        // Récupère les filtres de query qui est de type [key: value]. Le valeurs nil sont ignorées : seuls les filtres actifs vont dans l'URL
        let items = query.compactMap { key, value in
            
            value.map {
                
                URLQueryItem(name: key, value: $0)
                
            }
            
        }
        
        if !items.isEmpty {
            
            components.queryItems = items
        
        }
        // ---

        // Vérifie la route de base avec query params (ex: http://localhost:8080/appios/workshops?status=available) et la transforme en URL
        guard let url = components.url else {
            
            throw APIError.invalidURL
        
        }
        // ---
        
        // Configure la requête avec l'URL
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.value
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        
        // Ajoute le token si nécessaire
        if let token = try? keychain.readToken() {
            
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
        }

        if let body {
            
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try encoder.encode(body)
            
        }
        // ---

        // Envoie la requête
        let (data, response) = try await session.data(for: urlRequest)
        // ---

        // Reçoit la réponse du serveur en JSON
        guard let http = response as? HTTPURLResponse else {
            
            throw APIError.invalidResponse
            
        }
        // ---
        
        // Vérifie que le statut de la réponse soit pas en "échec"
        guard (200..<300).contains(http.statusCode) else {
            
            throw APIError.badStatus(http.statusCode)
            
        }
        // ---
        
        return data
        
    }

    // MARK: -- Fonction request() -- Envoie la requête et décode la réponse JSON dans le type attendu (en ModelResponse qui est Decodable)
    func request<T: Decodable>(path: String, method: HTTPMethod = .get, query: [String: String?] = [:], body: (any Encodable)? = nil) async throws -> T {
        
        // Attend la réponse du serveur en JSON
        let data = try await perform(path: path, method: method, query: query, body: body)
        // ---
        
        do {
            
            // Décode la réponse de la requête (en JSON) sous le Type (T) spécifié à l'utilisation (en ModelResponse qui est Decodable)
            return try decoder.decode(T.self, from: data)
            // ---
            
        } catch {
            
            throw APIError.decoding(error)
            
        }
        
    }
    
}
