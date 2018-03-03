import Routing
import Vapor
import Foundation
import Leaf
import HTTP
import WebSocket
import Console


public func routes(_ router: Router) throws {
    router.get("hello") { req -> Future<String> in
        return Future("Hello, World!")
    }
    
    router.get("chat") { (req) -> Future<View> in
        let leaf = try req.make(LeafRenderer.self)
        return leaf.render("Chat")
    }
    
    router.websocket("echo") { (req, ws) in
        ws.onString({ (ws, msg) in
            ws.send(string: msg)
        })
    }
    
    router.websocket("ping") { (req, ws) in
        ws.onString({ (ws, msg) in
            if msg == "ping" {
                ws.send(string: "pong")
            }
        })
    }
        //{"auth": "my auth token","command":"create","identifier": {"channel":"Participation"},"payload": {"participationId": 3,"longitude": 32.232,"latitude": 16.321}}
    /// Example
    /*
     {
     "date":537802942,
     "body":"hello!",
     "sender":"Me"
     }
     */
    router.websocket("message") { (req, masterWS) in
        let allJSONMessagesFuture
            = Future(())
                .allMessagesAsAJSONString(on: req)
                .catch()
        
       
        masterWS.send(future: allJSONMessagesFuture)
        
        masterWS.onString { (ws, msg) in
            let decoder = JSONDecoder()
            let message = try decoder.decode(Message.self, from: msg.data(using: .utf8)!)
            
            ws.send(future: save(message, on: req).allMessagesAsAJSONString(on: req).catch())
        }
    }
    
    router.websocket("demo") { (req, ws) in
        Message.query(on: req).all()
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
            self.send(string: msg)
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
                return Message
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


//extension Future where Expectation == String {
//    public func send(to websocket: WebSocket) -> Future<Expectation> {
//        return self.flatMap(to: Expectation.self) { (data) in
//            websocket.send(string: data)
//            return self
//        }
//    }
//}
//
//extension Future where Expectation == Data {
//    public func send(to websocket: WebSocket) -> Future<Expectation> {
//        return self.flatMap(to: Expectation.self) { (data) in
//            websocket.send(data: data)
//            return self
//        }
//    }
//}

