// all imports, I probably don't use some of these!
import QtQuick 2.12
import QtQuick.Window 2.12
import QtWebSockets 1.1
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQml 2.0

// the app window aka root
ApplicationWindow {
    id: root
    visible: true
    width: 640
    height: 480
    title: qsTr("Chat Coding Challenge")
    // these are some global variables used throughout the file 
    property bool sentByMe: false
    // names are used for senders and room id
    property string myName: "test"
    property string yourName: "Global"
    // activeUsers is an array to populate a model
    property var activeUsers: [];
    // global bool to help with current status
    property bool global: true
    // room objects to handle PM socket
    property var room: ({})

    // Login is the popup window when the app starts
    // it is the only file I could separate and have working 100%
    Login {id:log}

    // Turn the app into two uneven columns
    RowLayout {
        // Rectangle for asthetics
        Rectangle {
            id: userRect
            color: "darkgrey"
            width: 240
            height: 480
            Layout.fillHeight: true
            Layout.fillWidth: true

            // this is where the Users.js begins
            ListView {
                id: users
                Layout.fillHeight: true
                Layout.fillWidth: true
                anchors.fill: parent
                anchors.centerIn: parent
                // ToolBar used to create accent colors
                header: ToolBar {
                    width: 240
                    Label {
                        text: qsTr("Active Users")
                        font.pixelSize: 20
                        anchors.centerIn: parent
                    }
                }
                // the footer is actually a Button
                // it is here so the user can always return to the global chat
                footer: ToolBar {
                  width: 240
                  Button {
                    highlighted: true
                    text: qsTr("Global Chat")
                    font.pixelSize: 20
                    anchors.centerIn: parent
                    onPressed: {
                        // when pressed, the message list is cleared
                        listModel.clear()
                        global = true
                        yourName = "Global"
                        var loadRoom = {
                          type: "load",
                          room: yourName
                        }
                        // since we are in global, that is the room
                        // then the socket sends a request to index.js
                        // finally the message area is populated from MongoDB on return
                        socket.sendTextMessage(JSON.stringify(loadRoom));
                    }
                  }
                }
                // model for the users online
                model: userModel
                ListModel {
                    id: userModel
                }
                // model delegate
                delegate: RoundButton {
                    // a round button is used for asthetics and functionality
                    // the button can be pressed and the room updated
                    highlighted: false
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: user
                    font.pixelSize: 20
                    width: Math.min(implicitWidth + 20)
                    height: Math.min(implicitHeight)
                    onPressed: {
                        // again the messages are cleared
                        listModel.clear()
                        // we are not global, so this is now false
                        global = false;
                        yourName = this.text
                        var chat;
                        // the chatroom name is created by splicing the two names
                        if(myName <= yourName) chat = (myName + yourName)
                        else chat = (yourName + myName)
                        var loadRoom = {
                          type: "load",
                          room: chat
                        }
                        // the room is loaded from MongoDB
                        socket.sendTextMessage(JSON.stringify(loadRoom));
                    }
                }
                ScrollBar.vertical: ScrollBar{}
            }
        }
        // this is the right half of the screen which contains the messges and inputs
        Rectangle {
            height: 480
            width: 400
            // column is used to stack these objects
            ColumnLayout {
                anchors.fill: parent
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                // first a rectangle with a label to denote the active room
                Rectangle {
                    width: 400
                    height: 25
                    Layout.fillWidth: true
                    // move this up one layer to avoid anything passing infront of it on scroll
                    z: 1
                    color: "white"

                    Label {
                        Layout.fillWidth: true
                        font.pixelSize: 20
                        // yourName is used for chatroom name
                        text: "Room: " + yourName;
                    }
                }

                // list of all chat messages for any given room
                ListView {
                    id: msgList
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.margins: pane.leftPadding + inputMsg.leftPadding
                    verticalLayoutDirection: ListView.TopToBottom
                    spacing: 10
                    // model for the list
                    model: ListModel {
                        id: listModel
                    }
                    // delegate for message model
                    delegate: Column {
                        // column so there can be multiple stacked elements to a message
                        // sentByMe is used to determine the position and color of messages
                        // right are grey for yourself, blue and right for others
                        readonly property bool sentByMe: sender.text === myName || sender.text === "Me"
                        anchors.right: sentByMe ? msgList.contentItem.right : undefined
                        spacing: 5
                        // actual message box
                        Rectangle {
                            id: msg
                            property int wide: Math.max(messageText.implicitWidth + 24, 
                              sender.implicitWidth + 24)
                            width: Math.min(wide, 300)
                            height: messageText.implicitHeight + sender.implicitHeight + 24
                            color: sentByMe ? "lightgrey" : "steelblue"
                            Label {
                                anchors.fill: parent
                                anchors.centerIn: parent
                                anchors.margins: 9
                                // two texts in the column
                                // the sender, and the text message content
                                Column {
                                  Text { id: sender;
                                      width: 280;
                                      font.italic: true;
                                      font.underline: false;
                                      font.bold: true;
                                      visible: true;
                                      text: author;
                                      wrapMode: Label.Wrap
                                  }
                                  Text { id: messageText;
                                      text: message;
                                      width: 280;
                                      wrapMode: Label.Wrap
                                  }
                                }
                                wrapMode: Label.Wrap
                                color: sentByMe ? "black" : "white"
                            }
                        }
                        // label is used as a timestamp for the message.
                        // this is also stored in the DB so users can see activity at diff times
                        Label {
                            id: timestamp
                            width: Math.min(time.implicitWidth)
                            Text { id: time;
                                text: date
                                color: "lightgrey";
                                font.italic: true;
                            }
                            anchors.right: sentByMe ? parent.right : undefined
                        }
                    }
                    // ScrollBar so the messages can extend beyond the screen
                    ScrollBar.vertical: ScrollBar{}
                }
                // pane containing the text input and the send button
                Pane {
                    id: pane
                    Layout.fillWidth: true
                    // items are in a row, but the text field is dominant in size
                    RowLayout {
                        width: parent.width
                        TextField {
                            id: inputMsg
                            placeholderText: qsTr("Type Message...")
                            Layout.fillWidth: true
                            wrapMode: TextArea.Wrap
                            onAccepted: sendBtn.clicked()
                            // once submitted, the button does the rest
                        }
                        Button {
                            id: sendBtn
                            text: qsTr("Send")
                            enabled: inputMsg.length > 0
                            onClicked: {
                                // whether or not the user is in global chat matters
                                // if they are, a standard "msg" type is sent to the server
                                if(global === true) {
                                    // populate locale with the current time
                                    var locale = new Date().toLocaleTimeString(Qt.locale())
                                    var msg = {
                                      type: "msg",
                                      username: myName,
                                      text: inputMsg.text,
                                      time: locale
                                    }
                                    socket.sendTextMessage(JSON.stringify(msg))
                                }
                                // otherwise the message is a PM and the server needs to handle
                                // the data in other ways
                                else {
                                    // again the current time is grabbed
                                    locale = new Date().toLocaleTimeString(Qt.locale())
                                    room = {
                                        type: "pm",
                                        sender: myName,
                                        receiver: yourName,
                                        text: inputMsg.text,
                                        time: locale
                                    }
                                    socket.sendTextMessage(JSON.stringify(room))
                                }

                                // the signal is not sent back to the user, so the model is updated here.
                                // this could be changed, but when I initially wrote it without sockets,
                                // this is what I had
                                locale = new Date().toLocaleTimeString(Qt.locale())
                                listModel.append({"author": myName, "message": inputMsg.text, "date": locale})
                                msgList.contentY = 10000
                                inputMsg.clear() // the text field is cleared for re-use
                            }
                        }
                    }
                }
            }
        }
    }

    // all websocket handling occurs here
    // I tried to have this be a component from another file
    // It wasn't updating or using the global var properly so,
    // I moved it back to here to avoid issues.
    WebSocket {
      // id is socket, which is referenced by other code
      id: socket
      active: true
      url: "ws://localhost:8080"

      // bulk of the handling is here
      onTextMessageReceived: function(message){
        // first the data is parsed
        // similiar to the server, the data can take on many forms because of this
        var data = JSON.parse(message);
        // if the type is "msg"
        // global chat
        if (data.type === "msg") {
          // ensures you are in global to recieve the message
          if(global === true) {
            // uses locale if a timestamp wasn't provided;
            // used when bots share info
            var locale = new Date().toLocaleTimeString(Qt.locale())
            var stamp;
            if(data.time) stamp = data.time
            else stamp = locale
            // the message model is appended with the data: author, message, and date
            listModel.append({"author": data.username, "message": data.text, "date": stamp})
            msgList.contentY = 10000
          }
        }
        // used for personal messages
        else if (data.type === "pm") {
          // global is false, this prevents being PM'd in a different chat window
          if(global === false) {
            // uses locale if a timestamp wasn't provided;
            locale = new Date().toLocaleTimeString(Qt.locale())
            if(data.time) stamp = data.time
            else stamp = locale
            listModel.append({"author": data.username, "message": data.text, "date": stamp})
            msgList.contentY = 10000
          }
        }
        // used on client disconnect
        // loops through the model and removes the correct user from list
        else if(data.type === "client") {
            for(var z = 0; z < activeUsers.length; z++) {
                if(userModel.get(z).user === data.name) {
                    userModel.remove(z, 1);
                }
            }
            // changes the active users array as well
            for(var w = 0; w < activeUsers.length; w++) {
              if(activeUsers[w] === data.name) {
                activeUsers.splice(w, 1);
              }
            }
        }
        // finally, if we aren't in global, a DM, or a leaving client
        // this is used to add new users to the list
        else {
          var add = true; // true until false
          var users = JSON.parse(message);
          for(var i = 0; i < users.length; i ++) {
            add = true;
            // loops through activeUsers to see if the user exists
            for(var j = 0; j < activeUsers.length; j++) {
              if(users[i].name === activeUsers[j]) {
                add = false;
              }
            }
            // if add is still true in the end, the user can be appended
            // and the activeUsers gets updated
            if(add === true) {
              userModel.append({"user": users[i].name});
              activeUsers[j] = users[i].name
            }
          }
        }
      }
  }
}
