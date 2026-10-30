//
//  Reservation.swift
//  LineUpApp
//
//  Created by Apprenant174 on 26/10/2026.
//

import Foundation

struct Reservation: Identifiable, Hashable {
    let id: Int
    let status: ReservationStatus
    let workshopID: UUID
    let workshopName: String
    let categoryName: String
    let workshopDescription: String
    let startTime: Date
    let endTime: Date
    let userName: String

    var isOngoing: Bool {
        status == .validated && startTime <= Date.now && Date.now < endTime
    }

    var isUpcoming: Bool {
        status == .validated && Date.now < startTime
    }

    var isWaiting: Bool {
        status == .pending && Date.now < endTime
    }

    var isPast: Bool {
        endTime <= Date.now
    }
}
