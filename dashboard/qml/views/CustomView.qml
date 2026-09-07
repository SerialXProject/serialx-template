import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root
    spacing: 30

    Text {
        text: "CUSTOM"
        Layout.preferredWidth: 140
        font.pixelSize: 10
        color: appWindow.colorOnSurfaceVariant
        font.family: appWindow.monoFont.name
    }

    // Divisore verticale
    Rectangle {
        Layout.fillHeight: true
        width: 1
        color: appWindow.colorOutline
    }

  Text {
        text: "CUSTOM"
        Layout.preferredWidth: 140
        font.pixelSize: 10
        color: appWindow.colorOnSurfaceVariant
        font.family: appWindow.monoFont.name
    }
}
