const WebSocket = require('ws');
const uuid = require('uuid');
const mongoose = require("mongoose");
const User = require("./model/User");
const Message = require("./model/Message")

require("dotenv").config();

//connect to DB
mongoose.connect(process.env.DATABASE, {
  useCreateIndex: true,
  useUnifiedTopology: true,
  useNewUrlParser: true,
});

//Error checking
mongoose.connection.on("error", (err) => {
  console.log("Mongoose Connection ERROR: " + err.message);
});

//success
mongoose.connection.once("open", () => {
  console.log("MongoDB Connected");
});

const wss = new WebSocket.Server({ port: 8080 });

var connected_users = [];
console.log('WebSocket Listening on port 8080');

wss.on('connection', function connection(ws, request) {

  ws.client_id = uuid.v4();

  console.log('Client Id: ' + ws.client_id)
  var id = {
    type: "msg",
    username: "Chat Bot",
    text: "Client ID: " + ws.client_id
  }
  ws.send(JSON.stringify(id));

  ws.on('message', function incoming(message) {
    var data = JSON.parse(message);
    console.log('Server: %s %s', data.type, data.text);

    if(data.type == "load") {
      console.log(data.room)
      Message.find((err, dat) => {
        if(err)
          console.log(err);
        else
          dat.map((d) => {
            var info = {
              type: "msg",
              name: d.name,
              username: d.username,
              text: d.text,
              time: d.time
            }
            if(data.room != "Global") info.type = "pm";
            if(info.name == data.room) ws.send(JSON.stringify(info));

          }
      )})
    }

    else if(data.type == "user") {
      var user = {
        type: "id",
        id: ws.client_id,
        name: data.text
      }
      const newUser = new User({
        username: data.text,
      })
      //newUser.save()
      Message.find((err, data) => {
        if(err)
          console.log(err);
        else
          data.map((d) => {
            var info = {
              type: "msg",
              name: d.name,
              username: d.username,
              text: d.text,
              time: d.time
            }
            if(info.name == "Global") ws.send(JSON.stringify(info));
          }
      )})
      connected_users.push(user);
      console.log(connected_users);
      wss.clients.forEach(function(client) {
        client.send(JSON.stringify(connected_users));
      })
    }

    else if(data.type == "msg") {
      const newMessage = new Message({
        name: "Global",
        username: data.user,
        text: data.text,
        time: data.time,
      })
      newMessage.save();
      wss.clients.forEach(function(client) {
        if(client !== ws) client.send(JSON.stringify(data));
      })
    }

    else if(data.type == "pm") {
      var group;
      if(data.sender <= data.reciever) group = (data.sender + data.reciever);
      else group = (data.reciever + data.sender); 
      const newMessage = new Message({
        name: group,
        username: data.sender,
        text: data.text,
        time: data.time,
      })
      newMessage.save();
      for(var i = 0; i < connected_users.length; i++) {
        if(connected_users[i].name == data.reciever)
          var id = connected_users[i].id;
      }
      wss.clients.forEach(function(client) {
          if(id == client.client_id) {
            var msg = {
              type: "pm",
              username: data.sender,
              text: data.text
            }
            if(client != ws) client.send(JSON.stringify(msg));
          }
      })
    }
  })

  ws.on('close', function(){
    console.log('client dropped:', ws.client_id);
    var user;
    for(var i = 0; i < connected_users.length; i++) {
      if (connected_users[i].id == ws.client_id) {
        user = {
          type: "client",
          name: connected_users[i].name
        }
        connected_users.splice(i, 1);
      }
    }
    wss.clients.forEach(function(client) {
      client.send(JSON.stringify(user));
    })
    if(user) {
      var userLeave = {
        type: "msg",
        user: "Chat Bot",
        text: user.name + " has left the chat."
      }
      wss.clients.forEach(function(client) {
        client.send(JSON.stringify(userLeave));
      })
    }
  });

});
