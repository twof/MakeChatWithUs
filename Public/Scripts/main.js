var messages = []

function socketURI(path) {
    var loc = window.location, new_uri;
    var port = ""
    if (loc.port) {
        port = ":" + loc.port
    }
    return "ws://" + loc.hostname + port + path
}

function onSendMessage(sock) {
    var inputText = document.getElementById('messageInput').value;
    console.log("sending message")
    
    var msg = {
        header: "new_message",
        date: Date.now() / 1000,
        sender: "anon",
        body: inputText
    }
    sock.send(JSON.stringify(msg));
    
    console.log(JSON.stringify(msg))
}

function updateScroll(){
    var element = document.getElementById("output");
    element.scrollTop = element.scrollHeight;
}

window.onload = function () {
    var messageOutput = document.getElementById('output');
    var sock = new WebSocket(socketURI("/message"));

    var lastDate = Math.max(...messages.map(x => x["date"]))
    
    var msg = {
        header: "opening_context",
        date: lastDate / 1000
    }
    
    sock.send(JSON.stringify(msg));
    
    sock.onmessage = function (event) {
        messages.push(JSON.parse(event.data))
        document.getElementById('output').innerHTML += JSON.parse(event.data).map(x => "<p class=\"message\">" + x["body"] + "</p>").join("\n")
        updateScroll()
    }
    
    sock.onopen = function (event) {
        var lastDate = Math.max(...messages.map(x => x["date"]))
        
        var msg = {
            header: "opening_context",
            date: lastDate / 1000
        }
        
        sock.send(JSON.stringify(msg));
    };

    sock.onclose = function (event) {
        console.log(event);
    }

    sock.onerror = function (event) {
        console.log(event);
    }
    
    document.getElementById("messageInput")
        .addEventListener("keyup", function(event) {
            event.preventDefault();
            if (event.keyCode === 13) {
                document.getElementById("sendMessage").click();
                document.getElementById("messageInput").value = "";
            }
        });
    
    document.getElementById("sendMessage")
        .addEventListener("click", function(event) {
            event.preventDefault();
            onSendMessage(sock);
        });
}

