import Vapor

// Reçu uniquement par la route de modification de statut du back-office.
struct UpdateReservationsDTO: Content {
    var status: ReservationStatus
}
