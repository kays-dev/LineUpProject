import Fluent
import Vapor

struct ReservationResponseDTO: Content {
    var reservationID: UUID
    var status: ReservationStatus
    var workshopID: UUID
    var workshopName: String
    var startTime: Date
    var endTime: Date
    var userName: String
}

extension Reservations {
    // L'atelier et l'utilisateur doivent être chargés (.with(...) ou .load(on:)).
    func toDTO() throws -> ReservationResponseDTO {
        let reservationID = try requireID()

        return ReservationResponseDTO(
            reservationID: reservationID,
            status: status,
            workshopID: $workshop.id,
            workshopName: workshop.name,
            startTime: workshop.start_time,
            endTime: workshop.end_time,
            userName: user.name
        )
    }
}
