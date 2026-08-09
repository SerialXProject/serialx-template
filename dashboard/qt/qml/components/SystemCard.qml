import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string title: ""
    property string value: ""
    property bool isTime: false

    width: 200
    height: 100
    radius: 8
    color: appWindow.colorSurfaceLow

    Column {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10

        RowLayout {
            width: parent.width

            Text {
                text: root.title
                font.pixelSize: 10
                color: appWindow.colorOnSurfaceVariant
                font.family: appWindow.monoFont.name
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                width: 10
                height: 10
                radius: 2
                color: appWindow.colorPrimaryContainer
            }
        }

        Text {
            text: root.value
            color: root.isTime ? appWindow.colorPrimary : appWindow.colorOnSurface
            font.pixelSize: root.isTime ? 32 : 20
            font.family: appWindow.monoFont.name
        }
    }
}