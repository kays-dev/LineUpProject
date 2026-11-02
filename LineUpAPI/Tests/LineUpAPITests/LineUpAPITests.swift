import Foundation
@testable import LineUpAPI
import VaporTesting
import Testing
import Fluent

@Suite("App Tests with DB", .serialized)
struct LineUpAPITests {
    // Les tests ne dépendent pas du dossier de travail de Xcode : on lit les variables de
    // LineUpAPITest/.env (chemin déduit de ce fichier) : JWT_SECRET, identifiants MySQL,
    // TEST_DATABASE_NAME... Une variable déjà définie dans l'environnement est conservée.
    // Sans .env, un secret JWT de test est utilisé.
    static func loadEnvForTests() {
        let projectRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()   // LineUpAPITests
            .deletingLastPathComponent()   // Tests
            .deletingLastPathComponent()   // LineUpAPITest
        let envFile = projectRoot.appendingPathComponent(".env")
        if let content = try? String(contentsOf: envFile, encoding: .utf8) {
            for line in content.split(whereSeparator: \.isNewline) {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty, !trimmed.hasPrefix("#"),
                      let equal = trimmed.firstIndex(of: "=") else { continue }
                let key = trimmed[..<equal].trimmingCharacters(in: .whitespaces)
                var value = trimmed[trimmed.index(after: equal)...].trimmingCharacters(in: .whitespaces)
                if value.count >= 2, let first = value.first, let last = value.last,
                   (first == "\"" && last == "\"") || (first == "'" && last == "'") {
                    value = String(value.dropFirst().dropLast())
                }
                if !key.isEmpty {
                    setenv(key, value, 0)   // 0 : ne remplace pas une variable déjà définie
                }
            }
        }
        if getenv("JWT_SECRET") == nil {
            setenv("JWT_SECRET", "secret-de-test-uniquement", 1)
        }
    }
    func withApp(_ test: (Application) async throws -> ()) async throws {
        Self.loadEnvForTests()
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await app.autoMigrate()
            try await test(app)
            try await app.autoRevert()
        } catch {
            try? await app.autoRevert()
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
    
    @Test("Test Hello World Route")
    func helloWorld() async throws {
        try await withApp { app in
            try await app.testing().test(.GET, "hello", beforeRequest: { req in
                // Sans adresse client, Gatekeeper répond 403 « Unable to verify peer »
                req.headers.add(name: .xForwardedFor, value: "127.0.0.1")
            }, afterResponse: { res async in
                #expect(res.status == .ok)
                #expect(res.body.string == "Hello, world!")
            })
        }
    }
    
    
}
