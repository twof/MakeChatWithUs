window.onload = function () {
    var messageOutput = document.getElementById('output');
    var sock = new WebSocket("ws://localhost:8080/ping");

    sock.onopen = function (event) {
        sock.send("ping");
    }

    sock.onmessage = function (event) {
        console.log(event.data);
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
        console.log(event.data);
    }
}
