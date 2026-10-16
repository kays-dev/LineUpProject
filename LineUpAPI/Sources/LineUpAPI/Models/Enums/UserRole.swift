//
//  UserRole.swift
//  LineUpAPI
//
//  Created by Apprenant131 on 15/10/2026.
//

import Foundation

enum UserRole : String, Codable {
    case admin = "admin"
    case staff = "staff"
    case restaurant_manager = "restaurant_manager"
    case festivalgoer = "festivalgoer"
}

