//
//  Secret.swift
//  LineUpAPI
//
//  Created by apprenant144 on 31/10/2026.
//

import Vapor

enum Secrets {
    static let jwt: String = {
        guard let key = Environment.get("JWT_SECRET") else {
            fatalError("La variable d'environnement JWT_SECRET est manquante.")
        }
        return key
    }()
}
