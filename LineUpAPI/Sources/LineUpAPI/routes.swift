import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    // register controllers here (with project architecture order)
        // EXAMPLE ->
        // MyController
        // Space
        // MySecondController
    
    // start here
    try app.register(collection: UserController())
    
    try app.register(collection: CategoryController())
    
    try app.register(collection: WorkshopController())
    try app.register(collection: ReservationController())
    
    
    // ——————
}
