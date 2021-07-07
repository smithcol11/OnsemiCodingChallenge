// imports I used in main.qml
import QtQuick 2.12
import QtQuick.Window 2.12
import QtWebSockets 1.1
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQml 2.0

// login page is a popup that goes away when the user enters a name
Popup {
  id: popup
  height: 480
  width: 640
  dim: true
  visible: true
  anchors.centerIn: parent
  closePolicy: Popup.NoAutoClose // no auto close, must enter name

      Rectangle {
        id: rect
        color: "steelblue"
        height: 480
        width: 640
        anchors.centerIn: parent

        // there is a text field and button in a row
        // the text must be filled out in order to submitBtn
        // then the popup is closed
        RowLayout {
            Material.background: Material.Grey

            width: parent.width - 100
            anchors.centerIn: parent

            // enter name in text field
            TextField {
                id: inputName
                placeholderText: qsTr("Type Name...")
                Layout.fillWidth: true
                wrapMode: TextArea.Wrap
                onAccepted: submitBtn.clicked()
            }
            // button waiting for the valid submit
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
                    // the first active user is the current user
                    // the model is appended with this data
                    activeUsers[0] = myName
                    userModel.append({"user": myName})
                    // then the info is sent to the server and back
                    // this way all users can see the arriving guest
                    socket.sendTextMessage(JSON.stringify(user))
                    inputName.clear()
                    popup.close()
                }
            }
        }
    }
}

