window.onload = function () {
    var messageOutput = document.getElementById('output');
    var sock = new WebSocket("ws://localhost:8080/message");

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
}

function onSendMessage() {
    var sock = new WebSocket("ws://localhost:8080/message");
    var inputText = document.getElementById('messageInput').value;

    sock.onopen = function (event) {
        var msg = {
            date: Date.now() / 1000,
            sender: "anon",
            body: inputText
        }
        sock.send(JSON.stringify(msg));
    }

    sock.onmessage = function (event) {
        document.getElementById('output').innerHTML = JSON.parse(event.data).map(x => "<p>" + x["body"] + "</p>").join("\n")
        updateScroll()
    }
}

function updateScroll(){
    var element = document.getElementById("output");
    element.scrollTop = element.scrollHeight;
}
