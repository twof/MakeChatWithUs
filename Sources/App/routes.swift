import Routing
import Vapor
import Foundation
import Leaf
import HTTP
import FluentMySQL


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
            return try leaf.make("Chat")
        }
        
        router.websocket("ping") { (req, ws) in
            print("open")
            ws.onData({ (ws, data) in
                print("data", data)
            })
            ws.onString({ (ws, msg) in
                print("string")
                if msg == "ping" {
                    ws.send(string: "pong")
                }
            })
            ws.onByteBuffer({ (ws, byte) in
                print("byte", byte)
            })
        }
        
        router.websocket("message") { (req, ws) in
            ws.onString { (ws, msg) in
                let decoder = JSONDecoder()
                let message = try decoder.decode(Message.self, from: msg.data(using: .utf8)!)
                
                req.withConnection(to: .mysql) { (db) -> Future<Message> in
                    message.save(on: db).transform(to: message).do { message in
                        let encoder = JSONEncoder()
                        db.query(Message.self).all().do { (allMessages) in
                            let jsonMessage = try? encoder.encode(allMessages)
                            return ws.send(data: jsonMessage!)
                        }.catch { (error) in
                            print(error)
                        }
                    }
                }.catch { (err) in
                    print(err)
                    let encoder = JSONEncoder()
                    let jsonError = try? encoder.encode(["error":err.localizedDescription])
                    
                    ws.send(data: jsonError ?? Data())
                }
            }
        }
        
        router.get("allMessages") { (req) in
            return req.withConnection(to: .mysql, closure: { (db) in
                return db.query(Message.self).all()
            })
        }
    }
}
