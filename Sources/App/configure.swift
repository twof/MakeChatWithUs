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
    
    let websocketRouter = EngineWebSocketServer.default()
    websocketRoutes(websocketRouter)
    services.register(websocketRouter, as: WebSocketServer.self)
    print("register websockets")
    
    
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: TemplateRenderer.self)
    print("register leaf")
    
    try services.register(FluentMySQLProvider())
    
    var databaseConfig = DatabaseConfig()
    let db: MySQLDatabase
    
//    if let databaseURL = ProcessInfo.processInfo.environment["DATABASE_URL"] {
//        let mysqlConfig = MySQLDatabaseConfig(
//        let database = MySQLDatabase(config: databaseURL)
//        db = database
//        print("remote")
//    } else {
    
    let (username, password, host, database) = ("root", "pass", "localhost", "chat")
    let mysqlConfig = MySQLDatabaseConfig(hostname: host, username: username, password: password, database: database)
    
    db = MySQLDatabase(config: mysqlConfig)
//    }
    
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


