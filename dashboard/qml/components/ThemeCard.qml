import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string label: ""
    property color previewColor: "#000000"
    property bool active: false
    property bool isGradient: false

    signal clicked

    radius: 20
    color: active ? "#2A2A2A" : "#1A1A1A"
    border.width: active ? 2 : 1
    border.color: active ? "#4F8CFF" : "#333333"

    implicitHeight: 140
    implicitWidth: 100

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            radius: 14

            color: isGradient ? "transparent" : previewColor

            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: isGradient ? "#FFFFFF" : previewColor
                }

                GradientStop {
                    position: 1
                    color: isGradient ? "#121212" : previewColor
                }
            }
        }

        Text {
            text: root.label
            color: "white"
            font.pixelSize: 16
            font.bold: active
        }
    }
}
