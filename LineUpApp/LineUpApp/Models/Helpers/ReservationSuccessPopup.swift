//
//  ReservationSuccessPopup.swift
//  LineUpApp
//
//  Created by Apprenant131 on 01/11/2026.
//

import SwiftUI

struct ReservationSuccessPopup: View {

    @Environment(\.dismiss) private var dismiss

    let workshop: Workshop

    var body: some View {
        ZStack {
            Color.mintPrimary
                .ignoresSafeArea()

            if workshop.availability == .available {

                ConfettiView()

                StatusPopup(
                    type: .validation,
                    title: "Réservation confirmée !",
                    message:
                        "Votre réservation pour l’atelier a bien été enregistrée. Nous avons hâte de vous accueillir !",
                    buttonTitle: "Retour aux ateliers"
                ) {
                    dismiss()
                }
            } else {
                StatusPopup(
                    type: .validation,
                    title: "Inscription confirmée !",
                    message:
                        "Vous êtes bien inscrit sur la liste d’attente de cet atelier. Vous serez averti si une place se libère.",
                    buttonTitle: "compris !"
                ) {
                    dismiss()
                }
            }
        }
    }
}


#Preview {
    ReservationSuccessPopup(
        workshop: Workshop(
            id: UUID(),
            name: "Atelier théâtre",
            startTime: .now,
            endTime: .now.addingTimeInterval(3600),
            capacityMax: 20,
            subscriberNumber: 10,
            workshopDescription: "Découverte du théâtre",
            categoryID: UUID(),
            categoryName: "Théâtre",
            remainingPlaces: 10
        )
    )
}
