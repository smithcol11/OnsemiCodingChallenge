// const used with various requires
// ws, uuid, User, Message, and mongoose
const WebSocket = require('ws');
const uuid = require('uuid');
const User = require("./model/User");
const Message = require("./model/Message")

const mongoose = require("mongoose");

// this is the .env file for DB connection
require("dotenv").config();

// connect to MongoDB using .env
mongoose.connect(process.env.DATABASE, {
  useCreateIndex: true,
  useUnifiedTopology: true,
  useNewUrlParser: true,
});

// Error checking
mongoose.connection.on("error", (err) => {
  console.log("Mongoose Connection ERROR: " + err.message);
});

// success
mongoose.connection.once("open", () => {
  console.log("MongoDB Connected");
});

// wss is a new websocket server
const wss = new WebSocket.Server({ port: 8080 });

// connected users will keep track of active users
var connected_users = [];
// all_users keeps track of every user ever, and grabs the data from DB
// I was planning on adding functionality for messaging online & offline users.
// I didn't want to spend too much of my time doing tasks like this that weren't 
// outlined. But a lot of the code to implement it is already written.
var all_users = [];
console.log('WebSocket Listening on port 8080');

User.find((err, dat) => {
  if(err)
    console.log(err);
  else
    dat.map((d) => {
      var user = d.username;
      all_users.push(user);
    }
)})

// start of connection with client
// begins monitoring sends and requests
wss.on('connection', function connection(ws, request) {

  // this is the client_id for this connection
  ws.client_id = uuid.v4();

  console.log('Client Id: ' + ws.client_id)
  // I create an object id, then send it to the client
  // a bot tells them their id number
  var id = {
    type: "msg",
    username: "Chat Bot",
    text: "Client ID: " + ws.client_id
  }
  // I use JSON.stringify all over to ensure I can pass objects
  ws.send(JSON.stringify(id));

  // looks for message, bulk of back and forth is here
  ws.on('message', function incoming(message) {
    // once data is received, I parse it and store it in data
    // data is dynamic and can become many things in this instance
    var data = JSON.parse(message);

    // I pass a type with all my data for the server to interpret
    if(data.type == "load") {
      console.log(data.room)
      // this is how I grab the messages from MongoDB
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
            // if we are in global chat, the type is "msg"
            // else it is a personal message
            if(data.room != "Global") info.type = "pm";
            if(info.name == data.room) ws.send(JSON.stringify(info));
          }
      )})
    }

    // this is the message received upon a username entered
    else if(data.type == "user") {
      var user = {
        type: "id",
        id: ws.client_id,
        name: data.text
      }

      var add = true;
      for(var i = 0; i < all_users.length; i++) {
        if(all_users[i] == data.text) add = false;
      }
      if (add == true) {
        const newUser = new User({
          username: data.text,
        })
        console.log("Added user: " + newUser.username)
        newUser.save()
      }

      // this will load all messages in the global chat and display it to user
      // global is the default room everyone is loaded into
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
      // I push the new user onto connected_users
      // this way it is always known who is active
      connected_users.push(user);
      console.log(connected_users);
      // using forEach, I can send data to all clients
      // unless of course I have cases
      wss.clients.forEach(function(client) {
        client.send(JSON.stringify(connected_users));
      })
    }

    // this is the most common type
    // every time a message is sent in global, this is used
    else if(data.type == "msg") {
      // a new message is generated and then stored in the DB using .save()
      const newMessage = new Message({
        name: "Global",
        username: data.username,
        text: data.text,
        time: data.time,
      })
      newMessage.save();
      wss.clients.forEach(function(client) {
        if(client !== ws) client.send(JSON.stringify(data));
      })
    }

    // when it is a personal message, I use a similar technique I have used before
    // the names of the users are spliced together to ensure only those users can see the PM
    else if(data.type == "pm") {
      var group;
      if(data.sender <= data.receiver) group = (data.sender + data.receiver);
      else group = (data.receiver + data.sender); 
      const newMessage = new Message({
        name: group,
        username: data.sender,
        text: data.text,
        time: data.time,
      })
      newMessage.save();
      // Then I loop through and determine the receiver 
      for(var i = 0; i < connected_users.length; i++) {
        if(connected_users[i].name == data.receiver)
          var id = connected_users[i].id;
      }
      wss.clients.forEach(function(client) {
          // if your client id is correct, the message is sent 
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

  // when a socket is closing, the chat is informed via the bot
  // also, the user is removed from connected_users
  ws.on('close', function(){
    console.log('client dropped:', ws.client_id);
    var user;
    for(var i = 0; i < connected_users.length; i++) {
      if (connected_users[i].id == ws.client_id) {
        user = {
          type: "client",
          name: connected_users[i].name
        }
        // splice is used to remove the user
        connected_users.splice(i, 1);
      }
    }
    // this sends a signal to remove the user from the array in main.qml
    wss.clients.forEach(function(client) {
      client.send(JSON.stringify(user));
    })
    if(user) {
      var userLeave = {
        type: "msg",
        username: "Chat Bot",
        text: user.name + " has left the chat."
      }
      // sends to all connected clients
      wss.clients.forEach(function(client) {
        client.send(JSON.stringify(userLeave));
      })
    }
  });

});
