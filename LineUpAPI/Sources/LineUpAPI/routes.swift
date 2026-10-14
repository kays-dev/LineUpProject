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
    
    
    
    // ——————
}
