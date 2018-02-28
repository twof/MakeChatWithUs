import Vapor
import Leaf
import Foundation
import FluentPostgreSQL

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: TemplateRenderer.self)
    
    try services.register(FluentPostgreSQLProvider())
    
    var databaseConfig = DatabaseConfig()
    let psqlDBConfig: PostgreSQLDatabaseConfig

    if let databaseURL = ProcessInfo.processInfo.environment["DATABASE_URL"],
        let database = PostgreSQLDatabaseConfig(databaseURL: databaseURL) {
        psqlDBConfig = database
    } else {
        psqlDBConfig = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5433, username: "fnord")
    }

    let db = PostgreSQLDatabase(config: psqlDBConfig)
    databaseConfig.add(database: db, as: .psql)
    services.register(databaseConfig)

    var migrationConfig = MigrationConfig()
    migrationConfig.add(model: Message.self, database: .psql)
    services.register(migrationConfig)
}

extension PostgreSQLDatabaseConfig {
    /// Initialize MySQLDatabase with a DB URL
    public init?(databaseURL: String) {
        guard let url = URL(string: databaseURL),
            url.scheme == "mysql",
            url.pathComponents.count == 2,
            let hostname = url.host,
            let username = url.user,
            let intPort = url.port
            else {return nil}
        
        let dbPort = UInt16(intPort)
        let password = url.password
        let database = url.pathComponents[1]
        self.init(hostname: hostname, port: dbPort, username: username, database: database, password: password)
    }
}
