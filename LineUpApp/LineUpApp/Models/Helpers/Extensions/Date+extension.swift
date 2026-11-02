//
//  Date+extension.swift
//  LineUpApp
//
//  Created by Apprenant174 on 26/10/2026.
//

import Foundation

// MARK: Textes de date pour les écrans de réservation
extension Date {
    
    // Formattage des dates pour les écrans réservations, « Vendredi 3 septembre · 19:00 — 22:00 », dans la langue de l'appareil
    func scheduleText(until end: Date) -> String {
        
        let day = formatted(.dateTime.weekday(.wide).day().month(.wide))
        let startTime = formatted(date: .omitted, time: .shortened)
        let endTime = end.formatted(date: .omitted, time: .shortened)
        
        return "\(day.prefix(1).uppercased())\(day.dropFirst()) · \(startTime) — \(endTime)"
        
    }
    
    // Formattage des durées pour les écrans réservations, « 3 h », « 2 h 30 », dans la langue de l'appareil
    func durationText(until end: Date) -> String {
        
        Duration.seconds(end.timeIntervalSince(self))
            .formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
        
    }
    
}
