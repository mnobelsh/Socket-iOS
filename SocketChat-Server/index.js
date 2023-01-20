var app = require("express")();
var http = require("http").Server(app);
var io = require("socket.io")(http);

var userList = [];
var chatMessages = [];
var typingUsers = {};

app.get("/", function (req, res) {
  res.send("<h1>SocketChat Server</h1>");
});

http.listen(3000, function () {
  console.log("Listening on port: 3000");
});

io.on("connection", function (clientSocket) {
  console.log("Connection established with client");

  clientSocket.on("disconnect", function () {
    console.log("user disconnected");

    var clientUsername;
    for (var i = 0; i < userList.length; i++) {
      if (userList[i]["id"] == clientSocket.id) {
        userList[i]["isConnected"] = false;
        clientUsername = userList[i]["username"];
        break;
      }
    }

    delete typingUsers[clientUsername];
    io.emit("userList", userList);
    io.emit("userExitUpdate", clientUsername);
    io.emit("userTypingUpdate", typingUsers);
  });

  clientSocket.on("exitUser", function (clientUsername) {
    for (var i = 0; i < userList.length; i++) {
      if (userList[i]["id"] == clientSocket.id) {
        userList.splice(i, 1);
        break;
      }
    }
    io.emit("userExitUpdate", clientUsername);
  });

  clientSocket.on("startChat", function (clientUsername) {
    console.log(clientUsername + " starting a room chat...");
    io.emit("newChatMessage", chatMessages);
    io.emit("userList", userList);
  });

  clientSocket.on(
    "chatMessage",
    function (
      clientUsername,
      receiverUsername,
      message,
      imageBase64String,
      dateString
    ) {
      var newMessage = {};
      newMessage["senderUsername"] = clientUsername;
      newMessage["receiverUsername"] = receiverUsername;
      newMessage["message"] = message;
      newMessage["imageBase64String"] = imageBase64String;
      newMessage["date"] = dateString;
      chatMessages.push(newMessage);
      delete typingUsers[clientUsername];
      io.emit("userTypingUpdate", typingUsers);
      io.emit("newChatMessage", chatMessages);
    }
  );

  clientSocket.on("connectUser", function (clientUsername) {
    var message = "User " + clientUsername + " was connected.";
    console.log(message);

    var userInfo = {};
    var foundUser = false;
    for (var i = 0; i < userList.length; i++) {
      if (userList[i]["username"] == clientUsername) {
        userList[i]["isConnected"] = true;
        userList[i]["id"] = clientSocket.id;
        userInfo = userList[i];
        foundUser = true;
        break;
      }
    }

    if (!foundUser) {
      userInfo["id"] = clientSocket.id;
      userInfo["username"] = clientUsername;
      userInfo["isConnected"] = true;
      userList.push(userInfo);
    }

    io.emit("userList", userList);
    io.emit("userConnectUpdate", userInfo);
  });

  clientSocket.on("startType", function (clientUsername) {
    console.log("User " + clientUsername + " is writing a message...");
    typingUsers[clientUsername] = 1;
    io.emit("userTypingUpdate", typingUsers);
  });

  clientSocket.on("stopType", function (clientUsername) {
    console.log("User " + clientUsername + " has stopped writing a message...");
    delete typingUsers[clientUsername];
    io.emit("userTypingUpdate", typingUsers);
  });
});
