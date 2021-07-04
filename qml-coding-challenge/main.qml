import QtQuick 2.12
import QtQuick.Window 2.12
import QtWebSockets 1.1
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQml 2.0

ApplicationWindow {
    id: window
    visible: true
    width: 640
    height: 480
    title: qsTr("Chat Coding Challenge")
    property bool sentByMe: false
    property string myName: "test"
    property string yourName: "Global"
    property var activeUsers: [];
    property bool global: true
    property var room: ({})

    Popup {
      id: popup
      height: 340
      width: 420
      dim: true
      visible: true
      anchors.centerIn: parent
      closePolicy: Popup.NoAutoClose

          Rectangle {
            id: rect
            height: 340
            width: 420
            anchors.centerIn: parent
            color: "steelblue"

            RowLayout {
                width: parent.width - 50
                anchors.centerIn: parent

                TextField {
                    id: inputName
                    placeholderText: qsTr("Type Name...")
                    Layout.fillWidth: true
                    wrapMode: TextArea.Wrap
                    onAccepted: submitBtn.clicked()
                }
                Button {
                    id: submitBtn
                    text: qsTr("Submit")
                    enabled: inputName.length > 0
                    onClicked: {
                        console.log("Name Submitted")
                        myName = inputName.text
                        var user = {
                            type: "user",
                            text: myName
                        }
                        activeUsers[0] = myName
                        userModel.append({"user": myName})
                        socket.sendTextMessage(JSON.stringify(user))
                        inputName.clear()
                        popup.close()
                    }
                }
            }
        }
    }

    RowLayout {
        Rectangle {
            id: userRect
            color: "darkgrey"
            width: 240
            height: 480
            Layout.fillHeight: true
            Layout.fillWidth: true

            ListView {
                id: users
                Layout.fillHeight: true
                Layout.fillWidth: true
                anchors.fill: parent
                anchors.centerIn: parent
                header: ToolBar {
                    width: 240
                    Label {
                        text: qsTr("Active Users")
                        font.pixelSize: 20
                        anchors.centerIn: parent
                    }
                }
                footer: ToolBar {
                  width: 240
                  Button {
                    highlighted: true
                    text: qsTr("Global Chat")
                    font.pixelSize: 20
                    anchors.centerIn: parent
                    onPressed: {
                        listModel.clear()
                        global = true
                        yourName = "Global"
                        var loadRoom = {
                          type: "load",
                          room: yourName
                        }
                        socket.sendTextMessage(JSON.stringify(loadRoom));
                    }
                  }
                }
                model: userModel
                ListModel {
                    id: userModel
                }
                delegate: RoundButton {
                    highlighted: false
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: user
                    font.pixelSize: 20
                    width: Math.min(implicitWidth + 20)
                    height: Math.min(implicitHeight)
                    onPressed: {
                        listModel.clear()
                        global = false;
                        yourName = this.text
                        console.log(yourName)
                        var chat;
                        if(myName <= yourName) chat = (myName + yourName)
                        else chat = (yourName + myName)
                        var loadRoom = {
                          type: "load",
                          room: chat
                        }
                        socket.sendTextMessage(JSON.stringify(loadRoom));
                    }
                }
                ScrollBar.vertical: ScrollBar{}
            }
        }

        Rectangle {
            height: 480
            width: 400
            ColumnLayout {
                anchors.fill: parent
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    width: 400
                    height: 25
                    Layout.fillWidth: true
                    z: 1
                    color: "white"

                    Label {
                        Layout.fillWidth: true
                        font.pixelSize: 20
                        text: "Room: " + yourName;
                    }
                }

                ListView {
                    id: msgList
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.margins: pane.leftPadding + inputMsg.leftPadding
                    verticalLayoutDirection: ListView.TopToBottom
                    spacing: 10
                    model: ListModel {
                        id: listModel
                    }
                    delegate: Column {
                        readonly property bool sentByMe: sender.text === myName || sender.text === "Me"
                        anchors.right: sentByMe ? msgList.contentItem.right : undefined
                        spacing: 5

                        Rectangle {
                            id: msg
                            property int wide: Math.max(messageText.implicitWidth + 24, sender.implicitWidth + 24)
                            width: Math.min(wide, 300)
                            height: messageText.implicitHeight + sender.implicitHeight + 24
                            color: sentByMe ? "lightgrey" : "steelblue"
                            Label {
                                anchors.fill: parent
                                anchors.centerIn: parent
                                anchors.margins: 9
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

                    ScrollBar.vertical: ScrollBar{}
                }
                Pane {
                    id: pane
                    Layout.fillWidth: true
                    RowLayout {
                        width: parent.width
                        TextField {
                            id: inputMsg
                            placeholderText: qsTr("Type Message...")
                            Layout.fillWidth: true
                            wrapMode: TextArea.Wrap
                            onAccepted: sendBtn.clicked()
                        }
                        Button {
                            id: sendBtn
                            text: qsTr("Send")
                            enabled: inputMsg.length > 0
                            onClicked: {
                                console.log(inputMsg.text)
                                if(global === true) {
                                    var locale = new Date().toLocaleTimeString(Qt.locale())
                                    var msg = {
                                      type: "msg",
                                      user: myName,
                                      text: inputMsg.text,
                                      time: locale
                                    }
                                    socket.sendTextMessage(JSON.stringify(msg))
                                }
                                else {
                                    locale = new Date().toLocaleTimeString(Qt.locale())
                                    room = {
                                        type: "pm",
                                        sender: myName,
                                        reciever: yourName,
                                        text: inputMsg.text,
                                        time: locale
                                    }
                                    socket.sendTextMessage(JSON.stringify(room))
                                }

                                locale = new Date().toLocaleTimeString(Qt.locale())
                                listModel.append({"author": "Me", "message": inputMsg.text, "date": locale})
                                inputMsg.clear()
                            }
                        }
                    }
                }
            }
        }
    }

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
}
