import QtQuick 2.12
import QtQuick.Window 2.12
import QtWebSockets 1.1
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQml 2.0

Popup {
  id: popup
  height: 480
  width: 640
  dim: true
  visible: true
  anchors.centerIn: parent
  closePolicy: Popup.NoAutoClose

      Rectangle {
        id: rect
        height: 480
        width: 640
        anchors.centerIn: parent
        color: "steelblue"

        RowLayout {
            width: parent.width - 100
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

