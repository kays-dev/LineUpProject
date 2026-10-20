import Fluent
import Foundation

final class Reservation: Model, @unchecked Sendable {
    static let schema = "reservations"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "status")
    var status: ReservationStatus

    @Parent(key: "id_user")
    var user: User

    @Parent(key: "id_workshop")
    var workshop: Workshop

    init() { }

    init(
        id: UUID? = nil,
        status: ReservationStatus,
        userID: UUID,
        workshopID: UUID
    ) {
        self.id = id
        self.status = status
        self.$user.id = userID
        self.$workshop.id = workshopID
    }
}
