import Routing
import Vapor
import Foundation
import Leaf
import HTTP
import FluentMySQL
import WebSocket
import Console


/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
final class Routes: RouteCollection {
    /// Use this to create any services you may
    /// need for your routes.
    let app: Application

    /// Create a new Routes collection with
    /// the supplied application.
    init(app: Application) {
        self.app = app
    }

    /// See RouteCollection.boot
    func boot(router: Router) throws {
        router.get("hello") { req -> Future<String> in
            let os = ProcessInfo().operatingSystemVersion
            return Future(String(describing: os))
        }
        
        router.get("chat") { (req) -> Future<View> in
            let leaf = try req.make(LeafRenderer.self)
            return leaf.render("Chat")
        }
        
        router.post("test") { (req) -> Future<HTTPStatus> in
            let data = try req.body.makeData(max: Int.max).await(on: req)
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            print(json)
            
            return Future(HTTPStatus.ok)
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
        router.websocket("message") { (req, ws) in
            ws.onString { (ws, msg) in
                let decoder = JSONDecoder()
                let encoder = JSONEncoder()
                
                let allMessages
                    = try decoder.decode(Message.self, from: msg.data(using: .utf8)!)
                        .save(on: req)
                        .await(on: req)
                        .query(on: req)
                        .all()
                        .await(on: req)
                
                let allJSONMessages = try encoder.encode(allMessages).toString() ?? "error"
                
                ws.send(string: allJSONMessages)
            }
        }
        
        router.get("allMessages") { (req) in
            return req.withConnection(to: .sqlite, closure: { (db) in
                return db.query(Message.self).all()
            })
        }
    }
}

extension Data {
    func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}

