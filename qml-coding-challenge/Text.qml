import QtQuick 2.12
import QtQuick.Window 2.12
import QtWebSockets 1.1
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQml 2.0

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
              if(root.global === true) {
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
