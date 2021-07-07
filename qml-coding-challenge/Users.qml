import QtQuick 2.12
import QtQuick.Window 2.12
import QtWebSockets 1.1
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQml 2.0

// I intented to have this chunk of code be called from main.qml
// I couldn't get it to work because I attempt to access id's
// that exist in other files.
// This was going to handle the active users list
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
