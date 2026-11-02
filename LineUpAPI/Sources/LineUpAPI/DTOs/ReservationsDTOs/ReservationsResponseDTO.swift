import Fluent
import Vapor

struct ReservationsResponseDTO: Content {
    var reservationID: Int
    var status: ReservationStatus
    var workshop: WorkshopsResponseDTO
    var userName: String
    var userEmail: String
}

extension Reservations {
    // L'atelier (avec sa catégorie) et l'utilisateur doivent être chargés (.with(...) ou .load(on:)).
    func toDTO() throws -> ReservationsResponseDTO {
        let reservationID = try requireID()

        return ReservationsResponseDTO(
            reservationID: reservationID,
            status: status,
            workshop: try workshop.toDTO(),
            userName: user.name,
            userEmail: user.email
        )
    }
}
