import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: connectionMenuPopup
    property var homeViewModel // Passa il viewmodel per accedere alle sue funzioni se necessario
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    x: parent.width / 2 - width / 2
    y: parent.height / 2 - height / 2
    width: 300
    height: 200

    background: Rectangle {
        color: appWindow.colorSurfaceLow
        radius: 8
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Text {
            Layout.fillWidth: true
            text: "Seleziona la modalità di connessione"
            font.pixelSize: 18
            font.bold: true
            color: appWindow.colorOnSurface
            horizontalAlignment: Text.AlignHCenter
        }

        Item {
            Layout.fillHeight: true
        }

        Button {
            Layout.fillWidth: true
            height: 40
            text: "SerialX (Nativa)"
            font.pixelSize: 14
            font.bold: true
            contentItem: Text {
                text: parent.text
                font: parent.font
                color: parent.hovered ? appWindow.colorPrimary : "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                radius: 6
                color: parent.pressed ? "#1d4ed8" : "#60a5fa"
            }
            onClicked: {
                console.log("Connessione SerialX (Nativa) selezionata");
                // Qui potresti aggiungere la logica per la connessione SerialX
                connectionMenuPopup.close();
                appWindow.stack.push(Qt.resolvedUrl("../views/LoadingView.qml"));
            }
        }

        Button {
            Layout.fillWidth: true
            height: 40
            text: "Python (Consigliata)"
            font.pixelSize: 14
            font.bold: true
            contentItem: Text {
                text: parent.text
                font: parent.font
                color: parent.hovered ? appWindow.colorPrimary : "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                radius: 6
                color: parent.pressed ? "#1d4ed8" : "#60a5fa"
            }
            onClicked: {
                console.log("Connessione Python (Consigliata) selezionata");
                // Qui potresti aggiungere la logica per la connessione Python
                connectionMenuPopup.close();
                appWindow.stack.push(Qt.resolvedUrl("../views/LoadingView.qml"));
            }
        }
    }
}