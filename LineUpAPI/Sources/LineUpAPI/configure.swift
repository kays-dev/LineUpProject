import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor
import Gatekeeper

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
    
    
    // Configuration de CORS
    let corsConfiguration = CORSMiddleware.Configuration(
        // .all autorise toutes les origines a acceder à l'api
        allowedOrigin : .custom("http://localhost:8080"),
        // Specifie quel methode HTTP sont autorisé pour les requêtes cross-origin
        // OPTIONS: necessaire pour les request preflight
        allowedMethods: [.GET, .POST, .PUT, .PATCH, .DELETE, .OPTIONS],
        // Specifie quel en tête HTTP peuvent être envoye par le client lors de requête cross-origin
        allowedHeaders: [.accept, .authorization, .contentType, .origin],
        // Duree pendant laquelle le resultat d'une requete preflight est mis en cache par le navigateur
        cacheExpiration: 3600 * 24
    )
    
    // Ajout du middleware CORS à l'application
    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(corsMiddleware)
    
    // Gatekeeper: middleware conçu pour limiter le nombre de requête d'un client peut faire sur une periode définie
    app.caches.use(.memory)
    app.gatekeeper.config = .init(maxRequests: 100, per: .minute)
    app.middleware.use(GatekeeperMiddleware())
    
    
    // register routes
    try routes(app)
}
