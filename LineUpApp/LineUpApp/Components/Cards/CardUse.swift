//
//  CardUse.swift
//  LineUpApp
//
//  Created by Apprenant174 on 01/11/2026.
//

enum CardUse {
    case workshop(Availability)
    case reservation(ReservationStatus, availability: Availability)
}
