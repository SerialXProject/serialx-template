import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    property string label: ""
    property string value: ""
    property bool isTag: false
    Layout.fillWidth: true
    height: 45

    Rectangle {
        width: parent.width
        height: 1
        color: theme.outlineVariant
        opacity: 0.2
        anchors.bottom: parent.bottom
    }

    RowLayout {
        anchors.fill: parent
        Text {
            text: label
            color: theme.onSurfaceVariant
            font.pixelSize: 13
        }
        Item {
            Layout.fillWidth: true
        }
        Rectangle {
            visible: isTag
            height: 22
            width: valTxt.width + 16
            radius: 4
            color: Qt.rgba(163 / 255, 201 / 255, 255 / 255, 0.1)
            Text {
                id: valTxt
                anchors.centerIn: parent
                text: value
                color: theme.primary
                font.family: theme.monoFont
                font.pixelSize: 10
                font.weight: Font.Bold
            }
        }
        Text {
            visible: !isTag
            text: value
            color: theme.onSurface
            font.family: theme.monoFont
            font.pixelSize: 12
        }
    }
}
