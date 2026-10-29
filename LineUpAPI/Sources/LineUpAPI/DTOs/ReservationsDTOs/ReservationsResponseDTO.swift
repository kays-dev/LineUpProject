import Fluent
import Vapor

struct ReservationsResponseDTO: Content {
    var reservationID: Int
    var status: ReservationStatus
    var workshopID: UUID
    var workshopName: String
    var categoryName: String
    var startTime: Date
    var endTime: Date
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
            workshopID: $workshop.id,
            workshopName: workshop.name,
            categoryName: workshop.category.name,
            startTime: workshop.startTime,
            endTime: workshop.endTime,
            userName: user.name,
            userEmail: user.email
        )
    }
}
