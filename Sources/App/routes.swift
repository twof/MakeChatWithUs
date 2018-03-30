import Routing
import Vapor
import Foundation
import Leaf
import HTTP
import WebSocket
import Console

extension Array {
    mutating func removeIf(closure:((Element) -> Bool)) {
        for (index, element) in self.enumerated() {
            if closure(self[index]) {
                self.remove(at: index)
            }
        }
    }
}


public func routes(_ router: Router) throws {
    router.get("hello") { req -> String in
        return "Hello, World!"
    }
    
    router.get("chat") { (req) -> Future<View> in
        let leaf = try req.make(LeafRenderer.self)
        return leaf.render("Chat")
    }

    router.get("messages") { (req) in
        return Message.query(on: req).all()
    }
}

extension Data {
    func toString() -> String? {
        return String(data: self, encoding: .ascii)
    }
}

extension Content {
    public func json() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
}

extension WebSocket {
    func send(future: Future<String>) -> Void {
        _ = future.map(to: Void.self) { (msg) -> Void in
            self.send(msg)
        }
    }
}

func save(_ message: Message, on connectable: DatabaseConnectable) -> Future<Message> {
    return Message
        .query(on: connectable)
        .save(message)
}

extension Future {
    public func `catch`() -> Future<T> {
        return self.catch({ (err) in
            print(err)
        })
    }
}

extension Future {
    public func allMessagesAsAJSONString(on connectable: DatabaseConnectable) -> Future<String> {
        return self
            .flatMap(to: [Message].self) { (_) -> Future<[Message]> in
                return try Message
                    .query(on: connectable)
                    .sort(\Message.date, .ascending)
                    .all()
            }.map(to: String.self) { (allMessages) in
                guard let allJSONMessages = try allMessages.json().toString()
                    else {throw Abort(.internalServerError)}
                return allJSONMessages
            }
    }
}

