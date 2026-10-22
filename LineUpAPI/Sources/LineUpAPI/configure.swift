import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor

/// configures your application
func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Les tests annulent leurs migrations : ils utilisent une base distincte.
    let databaseName: String
    if app.environment == .testing {
        databaseName = Environment.get("TEST_DATABASE_NAME") ?? "lineup_tests"
    } else {
        databaseName = Environment.get("DATABASE_NAME") ?? "lineup"
    }

    app.databases.use(DatabaseConfigurationFactory.mysql(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 3306,
        username: Environment.get("DATABASE_USERNAME") ?? "root",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: databaseName
    ), as: .mysql)

    // register migrations here (with project architecture order)
        // EXAMPLE ->
        // MyMigration
        // Space
        // MySecondMigration
    
    // start here
    app.migrations.add(CreateUsers())
    
    app.migrations.add(CreateCategories())
    
    app.migrations.add(CreateWorkshops())
    
    app.migrations.add(CreateReservations())
    
    
    
    // ——————
    
    // register routes
    try routes(app)
}
