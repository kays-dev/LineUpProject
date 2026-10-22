import Vapor

// Paramètres de l'URL : userID (UUID), name, status et workshopID (UUID).
struct ReservationsQueryDTO: Content {
    var name: String?
    var status: ReservationStatus?
    var workshopID: UUID?

    // Obligatoire pour la liste /reservations, facultatif pour la liste globale.
    var userID: UUID?
}
