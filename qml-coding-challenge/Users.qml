import QtQuick 2.12
import QtQuick.Window 2.12
import QtWebSockets 1.1
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQml 2.0

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

