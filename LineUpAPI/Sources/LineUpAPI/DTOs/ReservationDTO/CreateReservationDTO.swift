import Vapor

struct CreateReservationDTO: Content {
    var userID: UUID
    var workshopID: UUID

    func toModel(status: ReservationStatus) -> Reservations {
        return Reservations(
            status: status,
            userID: userID,
            workshopID: workshopID
        )
    }
}
