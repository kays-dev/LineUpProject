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
    let workshop: WorkshopResponse
    let userName: String
}

extension ReservationResponse {
    func toModel() -> Reservation {
        Reservation(
            id: reservationID,
            status: status,
            workshop: workshop.toModel(),
            userName: userName
        )
    }
}
