import Foundation
import FluentSQLite
import Vapor

final class Message: Content {
    public var id: UUID? = nil
    public var date: Date = Date()
    public var body: String
    public var sender: String
    
    init(id: UUID?=nil, date: Date=Date(), body: String, sender: String) {
        self.id = id
        self.date = date
        self.body = body
        self.sender = sender
    }
    
//    private enum CodingKeys: String, CodingKey {
//        case body
//        case sender
//    }
}

extension Message: Model, Migration {
    typealias Database = SQLiteDatabase
    typealias ID = UUID
    
    static var idKey: IDKey {
        return \.id
    }
}
