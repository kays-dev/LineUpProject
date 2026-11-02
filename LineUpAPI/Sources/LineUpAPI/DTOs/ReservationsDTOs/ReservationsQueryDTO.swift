import Vapor

// Filtres facultatifs de la liste du back-office :
// ?status=pending&workshop=<id de l'atelier>&search=<nom ou email du festivalier>
// La pagination (?page=&per=) est lue directement par Vapor.
struct ReservationsQueryDTO: Content {
    var status: ReservationStatus?
    var workshop: UUID?
    var search: String?
}
