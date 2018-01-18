import Vapor
import FluentMySQL
import Leaf
import Foundation
import FluentSQLite

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    try services.register(LeafProvider())
    try services.register(FluentSQLiteProvider())
    
    var databaseConfig = DatabaseConfig()
    let db = try SQLiteDatabase(storage: .memory)
    databaseConfig.add(database: db, as: .sqlite)
    
    services.register(databaseConfig)
    
    var migrationConfig = MigrationConfig()
    migrationConfig.add(model: Message.self, database: .sqlite)
    services.register(migrationConfig)
    
    
    
    // configure your application here
//    try services.register(FluentMySQLProvider())
//
//    var databaseConfig = DatabaseConfig()
//    var (username, password, host, database) = ("root", "pass", "localhost", "bathroom")
//
//    if let databaseURL = ProcessInfo.processInfo.environment["DATABASE_URL"] {
//        let tokens = databaseURL
//            .replacingOccurrences(of: "mysql://", with: "")
//            .replacingOccurrences(of: "?reconnect=true", with: "")
//            .split { ["@", "/", ":"].contains(String($0)) }
//
//        (username, password, host, database) = (String(tokens[0]), String(tokens[1]), String(tokens[2]), String(tokens[3]))
//    }
//
//    print("using local db")
//
//    let db = MySQLDatabase(hostname: host, user: username, password: password, database: database)
//    databaseConfig.add(database: db, as: .mysql)
//    services.register(databaseConfig)
//
//    var migrationConfig = MigrationConfig()
//    migrationConfig.add(model: Message.self, database: .mysql)
//    services.register(migrationConfig)
}

extension DatabaseIdentifier {
    static var mysql: DatabaseIdentifier<MySQLDatabase> {
        return .init("mysql")
        
    }
    
    static var sqlite: DatabaseIdentifier<SQLiteDatabase> {
        return .init("sqlite")
    }
}
