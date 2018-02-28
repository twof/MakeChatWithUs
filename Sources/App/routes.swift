import Routing
import Vapor
import Foundation
//import Leaf
import HTTP
//import FluentMySQL
import WebSocket
import Console


public func routes(_ router: Router) throws {
    router.get("hello") { req -> Future<String> in
        let os = ProcessInfo().operatingSystemVersion
        return Future(String(describing: os))
    }
    
    //        router.get("chat") { (req) -> Future<View> in
    //            let leaf = try req.make(LeafRenderer.self)
    //            return leaf.render("Chat")
    //        }
    
    router.post("test") { (req) -> Future<HTTPStatus> in
        let data = try req.http.body.makeData(max: Int.max).await(on: req)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        print(json)
        
        return Future(HTTPStatus.ok)
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
    
    
    /// Example
    /*
     {
     "date":537802942,
     "body":"hello!",
     "sender":"Me"
     }
     */
    //        router.websocket("message") { (req, websocket) in
    //            websocket.onString { (ws, msg) in
    //                let decoder = JSONDecoder()
    //                let encoder = JSONEncoder()
    //                let message = try decoder.decode(Message.self, from: msg.data(using: .utf8)!)
    //
    //                let allJSONMessagesFuture = req.withPooledConnection(to: .psql, closure: { (conn) in
    //                    return conn
    //                        .query(Message.self)
    //                        .save(message)
    //                        .flatMap(to: [Message].self) { (_) -> Future<[Message]> in
    //                            return conn.query(Message.self).all()
    //                        }.map(to: String.self) { (allMessages) in
    //                            guard let allJSONMessages = try encoder.encode(allMessages).toString()
    //                                else {throw Abort(.internalServerError)}
    //                            return allJSONMessages
    //                        }.catch({ (err) in
    //                            print(err)
    //                        })
    //                })
    //
    //                ws.send(future: allJSONMessagesFuture)
    //            }
    //        }
    //
    router.websocket("test") { (req, ws) in
        ws.onString({ (ws, msg) in
            _ = Message
                .query(on: req)
                .all()
                .map(to: String.self) { allMessages in
                    let encoder = JSONEncoder()
                    guard let allJSONMessages = try encoder.encode(allMessages).toString()
                        else {throw Abort(.internalServerError)}
                    return allJSONMessages
                }.map(to: Void.self) { messageStrings in
                    print(messageStrings)
                    return ws.send(string: messageStrings)
            }
        })
    }
    
    router.websocket("demo") { (req, ws) in
        ws.onString({ (ws, msg) in
            _ = Future(msg)
                .send(to: ws)
        })
    }
    
    router.get("messages") { (req) in
        return Message.query(on: req).all()
    }
}

extension Data {
    func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}

extension WebSocket {
    func send(future: Future<String>) -> Void {
        _ = future.map(to: Void.self) { (msg) -> Void in
            self.send(string: msg)
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

