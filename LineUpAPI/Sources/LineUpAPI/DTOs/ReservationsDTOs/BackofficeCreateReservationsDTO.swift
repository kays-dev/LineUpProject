import Vapor

struct BackofficeCreateReservationsDTO: Content {
    var userID: UUID
    var workshopID: UUID

    func toModel() -> Reservations {
        return Reservations(
            status: .pending,
            userID: userID,
            workshopID: workshopID
        )
    }
}
