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
    let workshop: Workshop
    let userName: String

    var isOngoing: Bool {
        status == .validated && workshop.startTime <= Date.now && Date.now < workshop.endTime
    }

    var isUpcoming: Bool {
        status == .validated && Date.now < workshop.startTime
    }

    var isWaiting: Bool {
        status == .pending && Date.now < workshop.endTime
    }

    var isPast: Bool {
        workshop.endTime <= Date.now
    }
}
