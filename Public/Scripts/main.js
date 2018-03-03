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

    sock.onmessage = function (event) {
        console.log(JSON.parse(event.data).map(x => x["body"]))
        document.getElementById('output').innerHTML = JSON.parse(event.data).map(x => "<p class=\"message\">" + x["body"] + "</p>").join("\n")
        updateScroll()
    }

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

