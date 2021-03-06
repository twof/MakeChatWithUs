import Foundation
import FluentMySQL
import Vapor

final public class Message: Content {
    public var id: UUID?
    public var date: Date
    public var body: String
    public var sender: String
    
    init(id: UUID?=nil, date: Date=Date(), body: String, sender: String) {
        self.id = id
        self.date = date
        self.body = body
        self.sender = sender
    }
}

extension Message: MySQLUUIDModel, Migration {
}

