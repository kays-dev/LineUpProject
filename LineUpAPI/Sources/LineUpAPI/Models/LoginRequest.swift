//
//  LoginRequest.swift
//  TestLineUp
//
//  Created by apprenant144 on 23/10/2026.
//
import Vapor

struct LoginRequest: Content {
    let email: String
    let password: String
}
