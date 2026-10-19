import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: connectionMenuPopup
    property var homeViewModel
    property var customViewModel

    // Segnali che notificano la scelta dell'utente, senza contenere logica
    signal serialXSelected()
    signal pythonSelected()

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

    // Connetti ai signals del CustomViewModel
    Connections {
        target: customViewModel
        function onScriptGenerated(script, success, message, file_path) {
            console.log("Script generated event:")
            console.log("  Success:", success)
            console.log("  Message:", message)
            console.log("  File path:", file_path)
            
            if (success) {
                console.log("✓ Script saved to:", file_path)
            } else {
                console.error("✗ Script generation failed:", message)
            }
        }
        
        function onConnectionStarted(message) {
            console.log("Connection started:", message)
        }
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
                connectionMenuPopup.close();
                connectionMenuPopup.serialXSelected();
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
                connectionMenuPopup.close();
                connectionMenuPopup.pythonSelected();
            }
        }
    }
}