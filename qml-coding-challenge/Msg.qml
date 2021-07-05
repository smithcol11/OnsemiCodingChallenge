import QtQuick 2.12
import QtQuick.Window 2.12
import QtWebSockets 1.1
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQml 2.0

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
        readonly property bool sentByMe: sender.text === root.myName || sender.text === "Me"
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
