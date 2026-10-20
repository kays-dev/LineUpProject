import Vapor

// Reçu uniquement par la route de modification de statut du back-office.
struct UpdateReservationDTO: Content {
    var status: ReservationStatus
}
