//
//  ReservationResponse.swift
//  LineUpApp
//
//  Created by Apprenant174 on 29/10/2026.
//

import Foundation

struct ReservationResponse: Decodable {
    let reservationID: Int
    let status: ReservationStatus
    let workshopID: UUID
    let workshopName: String
    let categoryName: String
    let workshopDescription: String
    let startTime: Date
    let endTime: Date
    let userName: String
}

extension ReservationResponse {
    func toModel() -> Reservation {
        Reservation(
            id: reservationID,
            status: status,
            workshopID: workshopID,
            workshopName: workshopName,
            categoryName: categoryName,
            workshopDescription: workshopDescription,
            startTime: startTime,
            endTime: endTime,
            userName: userName
        )
    }
}
