import Fluent
import Vapor

struct ReservationResponseDTO: Content {
    var reservationID: UUID
    var status: ReservationStatus
    var workshopID: UUID
}

extension Reservation {
    func toDTO() throws -> ReservationResponseDTO {
        let reservationID = try requireID()

        return ReservationResponseDTO(
            reservationID: reservationID,
            status: status,
            workshopID: $workshop.id
        )
    }
}
