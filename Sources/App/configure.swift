import Vapor
import Leaf
import Foundation
import FluentMySQL

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
    print("register router")
    
//    try services.register(EngineServerConfig.detect())
    
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: TemplateRenderer.self)
    print("register leaf")
    
    try services.register(FluentMySQLProvider())
    
    var databaseConfig = DatabaseConfig()
    let db: MySQLDatabase
    
    if let databaseURL = ProcessInfo.processInfo.environment["DATABASE_URL"],
        let database = MySQLDatabase(databaseURL: databaseURL) {
        db = database
        print("remote")
    } else {
        let (username, password, host, database) = ("root", "pass", "localhost", "chat")
        db = MySQLDatabase(hostname: host, user: username, password: password, database: database)
        print("local")
    }
    
    databaseConfig.add(database: db, as: .mysql)
    services.register(databaseConfig)
    
    var migrationConfig = MigrationConfig()
    migrationConfig.add(model: Message.self, database: .mysql)
    services.register(migrationConfig)
    print("register migration config")
}

extension DatabaseIdentifier {
    public static var mysql: DatabaseIdentifier<MySQLDatabase> {
        return .init("mysql")
    }
}

//extension PostgreSQLDatabaseConfig {
//    /// Initialize MySQLDatabase with a DB URL
//    public init?(databaseURL: String) {
//        guard let url = URL(string: databaseURL),
//            url.scheme == "mysql",
//            url.pathComponents.count == 2,
//            let hostname = url.host,
//            let username = url.user,
//            let intPort = url.port
//            else {return nil}
//
//        let dbPort = UInt16(intPort)
//        let password = url.password
//        let database = url.pathComponents[1]
//        self.init(hostname: hostname, port: dbPort, username: username, database: database, password: password)
//    }
//}

/// psql setup
//try services.register(FluentPostgreSQLProvider())
//print("register fluent psql provider")
//var databaseConfig = DatabaseConfig()
//let psqlDBConfig: PostgreSQLDatabaseConfig
//
//if let databaseURL = ProcessInfo.processInfo.environment["DATABASE_URL"],
//    let database = PostgreSQLDatabaseConfig(databaseURL: databaseURL) {
//    psqlDBConfig = database
//    print("heroku")
//} else {
//    print("local")
//    psqlDBConfig = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5433, username: "fnord")
//}
//
//let db = PostgreSQLDatabase(config: psqlDBConfig)
//databaseConfig.add(database: db, as: .psql)
//services.register(databaseConfig)
//print("register db config")

