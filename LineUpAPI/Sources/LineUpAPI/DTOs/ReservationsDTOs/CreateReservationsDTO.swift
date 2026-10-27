import Vapor

// JSON envoyé par l'app pour réserver : { "workshopID": "..." }.
// L'utilisateur n'est pas dans le JSON : il est lu dans le token.
struct CreateReservationsDTO: Content {
    var workshopID: UUID

    func toModel(status: ReservationStatus, userID: UUID) -> Reservations {
        return Reservations(
            status: status,
            userID: userID,
            workshopID: workshopID
        )
    }
}
