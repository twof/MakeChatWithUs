import Vapor

public extension WebSocket {
    public static func broadcast(msg: String, to all: [WebSocket]) {
        all.forEach { $0.send(msg) }
    }
    
    public static func broadcast(future: Future<String>, to all: [WebSocket]) {
        all.forEach { $0.send(future: future) }
    }
}

public func websocketRoutes(_ server: EngineWebSocketServer) {
    server.get("echo") { (ws, req) in
        ws.onText { (msg) in
            ws.send(msg)
        }
    }
    
    var pingSessions: [WebSocket] = []

    server.get("ping") { (ws, req) in
        pingSessions.append(ws)
        
        ws.onText { (msg) in
            if msg == "ping" {
                WebSocket.broadcast(msg: "pong", to: pingSessions)
            }
        }
        
        ws.onClose {
            pingSessions.removeIf { $0 === ws }
            print(pingSessions)
        }
    }
    
    var chatSessions: [WebSocket] = []
    /// Example
    /*
     {
     "date":537802942,
     "body":"hello!",
     "sender":"Me"
     }
     */
    server.get("message") { (ws, req) in
        let allJSONMessagesFuture
            = Future.map(on: req) {()}
                .allMessagesAsAJSONString(on: req)
                .catch()

        ws.send(future: allJSONMessagesFuture)
        chatSessions.append(ws)

        ws.onText { (msg) in
            let decoder = JSONDecoder()
            guard let message = try? decoder.decode(Message.self, from: msg.data(using: .utf8)!) else {
                ws.send("invalid message")
                return
            }

            WebSocket.broadcast(future: save(message, on: req).allMessagesAsAJSONString(on: req).catch(), to:
                chatSessions)
        }

        ws.onClose {
            chatSessions.removeIf { $0 === ws }
            print(chatSessions)
        }
    }
}
