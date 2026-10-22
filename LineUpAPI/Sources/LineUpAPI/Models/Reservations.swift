import Fluent
import Foundation

final class Reservations: Model, @unchecked Sendable {
    static let schema = "reservations"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "status")
    var status: ReservationStatus

    @Parent(key: "id_user")
    var user: Users

    @Parent(key: "id_workshop")
    var workshop: Workshops

    init() { }

    init(
        id: Int? = nil,
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
