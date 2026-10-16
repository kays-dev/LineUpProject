import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor

/// configures your application
func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.mysql(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 3306,
        username: Environment.get("DATABASE_USERNAME") ?? "root",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "lineup"
    ), as: .mysql)

    // register migrations here (with project architecture order)
        // EXAMPLE ->
        // MyMigration
        // Space
        // MySecondMigration
    
    // start here
    app.migrations.add(CreateCategory())
    
    app.migrations.add(CreateWorkshop())
    
    
    
    // ——————
    
    // register routes
    try routes(app)
}
