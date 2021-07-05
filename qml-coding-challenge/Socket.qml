import QtQuick 2.12
import QtQuick.Window 2.12
import QtWebSockets 1.1
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQml 2.0

WebSocket {
    id: socket
    active: true
    url: "ws://localhost:8080"

    onTextMessageReceived: function(message){
      var data = JSON.parse(message);
      if (data.type === "msg") {
        if(global === true) {
          var locale = new Date().toLocaleTimeString(Qt.locale())
          var stamp;
          if(data.time) stamp = data.time
          else stamp = locale
          listModel.append({"author": data.username, "message": data.text, "date": stamp})
        }
      }
      else if (data.type === "pm") {
        locale = new Date().toLocaleTimeString(Qt.locale())
        if(data.time) stamp = data.time
        else stamp = locale
        listModel.append({"author": data.username, "message": data.text, "date": stamp})
      }
      else if(data.type === "client") {
          for(var z = 0; z < activeUsers.length; z++) {
            console.log("in model loop")
              if(userModel.get(z).user === data.name) {
                  userModel.remove(z, 1);
              }
          }
        for(var w = 0; w < activeUsers.length; w++) {
          if(activeUsers[w] === data.name) {
            activeUsers.splice(w, 1);
          }
        }
      }
      else {
        var add = true;
        var users = JSON.parse(message);
        for(var i = 0; i < users.length; i ++) {
          add = true;
          for(var j = 0; j < activeUsers.length; j++) {
            if(users[i].name === activeUsers[j]) {
              add = false;
            }
          }
          if(add === true) {
            userModel.append({"user": users[i].name});
            activeUsers[j] = users[i].name
          }
        }
      }
    }
}
