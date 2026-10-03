import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root
    spacing: 30

    // Stato connessione seriale (prima non era dichiarato in questo file)
    QtObject {
        id: serialState
        property bool connecting: false
    }

    Connections {
        target: varEditViewModel || null
        function onVariableSent(name, success, message) {
            console.log(message);
        }
        function onFunctionRun(name, success, message) {
            console.log(message);
        }
        function onSerialConnectionStarted() {
            serialState.connecting = true;
            console.log("Serial connection started...");
        }

        function onSerialConnectionFinished(success, message) {
            serialState.connecting = false;
            console.log("Serial connection finished: " + message);
            if (success) {
                console.log("Variables loaded from serial connection");
            } else {
                console.log("Connection error: " + message);
            }
        }
    }

    // ============ COLONNA 1 — VARIABLES ============
    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredWidth: 1
        spacing: 12

        Text {
            text: "VARIABLES"
            font.pixelSize: 12
            font.bold: true
            font.letterSpacing: 1
            color: appWindow.colorOnSurfaceVariant
            font.family: appWindow.monoFont.name
        }

        // Header colonne
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "NAME"
                Layout.preferredWidth: 140
                font.pixelSize: 10
                color: appWindow.colorOnSurfaceVariant
                font.family: appWindow.monoFont.name
            }
            Text {
                text: "TYPE"
                Layout.preferredWidth: 60
                font.pixelSize: 10
                color: appWindow.colorOnSurfaceVariant
                font.family: appWindow.monoFont.name
            }
            Text {
                text: "VALUE"
                Layout.fillWidth: true
                font.pixelSize: 10
                color: appWindow.colorOnSurfaceVariant
                font.family: appWindow.monoFont.name
            }
            Item {
                Layout.preferredWidth: 70
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: appWindow.colorOutline
        }

        // Contenitore: lista + messaggio centrato (fratelli, non padre/figlio)
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: variablesList
                anchors.fill: parent
                clip: true
                spacing: 8
                model: varEditViewModel ? varEditViewModel.variables : []

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 44
                    radius: 8
                    color: appWindow.colorSurface

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10

                        Text {
                            text: modelData.name
                            Layout.preferredWidth: 140
                            font.pixelSize: 12
                            color: appWindow.colorOnSurface
                            font.family: appWindow.monoFont.name
                            elide: Text.ElideRight
                        }

                        Text {
                            text: modelData.type
                            Layout.preferredWidth: 60
                            font.pixelSize: 11
                            color: appWindow.colorOnSurfaceVariant
                            font.family: appWindow.monoFont.name
                        }

                        TextField {
                            id: valueField
                            Layout.fillWidth: true
                            text: modelData.value
                            property bool importedValue: modelData.imported === true
                            color: importedValue ? (appWindow.isDark ? "#81c784" : "#187a36") : appWindow.colorOnSurface
                            font.pixelSize: 12
                            font.family: appWindow.monoFont.name
                            selectByMouse: true
                            onTextEdited: {
                                importedValue = false;
                                if (varEditViewModel) {
                                    varEditViewModel.updateVariableValue(index, text);
                                }
                            }

                            background: Rectangle {
                                radius: 6
                                color: appWindow.colorSurfaceHigh
                                border.color: appWindow.colorOutline
                                border.width: 1
                            }
                        }

                        Button {
                            Layout.preferredWidth: 70
                            Layout.preferredHeight: 30
                            enabled: varEditViewModel !== null && modelData.can_set
                            onClicked: {
                                if (varEditViewModel) {
                                    varEditViewModel.setVariable(modelData.type, modelData.name, valueField.text);
                                }
                            }

                            background: Rectangle {
                                radius: 6
                                color: parent.enabled ? appWindow.colorPrimary : appWindow.colorOutline
                            }

                            contentItem: Text {
                                text: "INVIA"
                                font.pixelSize: 10
                                font.bold: true
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: variablesList.count === 0
                text: serialState.connecting ? "Connessione in corso..." : "Connetti un dispositivo"
                font.pixelSize: 14
                color: appWindow.colorOnSurfaceVariant
                font.family: appWindow.monoFont.name
            }
        }
    }

    // Divisore verticale
    Rectangle {
        Layout.fillHeight: true
        Layout.preferredWidth: 1
        color: appWindow.colorOutline
    }

    // ============ COLONNA 2 — FUNCTIONS ============
    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredWidth: 1
        spacing: 12

        Text {
            text: "FUNCTIONS"
            font.pixelSize: 12
            font.bold: true
            font.letterSpacing: 1
            color: appWindow.colorOnSurfaceVariant
            font.family: appWindow.monoFont.name
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "NAME"
                Layout.fillWidth: true
                font.pixelSize: 10
                color: appWindow.colorOnSurfaceVariant
                font.family: appWindow.monoFont.name
            }
            Item {
                Layout.preferredWidth: 70
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: appWindow.colorOutline
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: functionsList
                anchors.fill: parent
                clip: true
                spacing: 8
                model: varEditViewModel ? varEditViewModel.functions : []

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 44
                    radius: 8
                    color: appWindow.colorSurface

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10

                        Text {
                            text: modelData.name
                            Layout.fillWidth: true
                            font.pixelSize: 12
                            color: appWindow.colorOnSurface
                            font.family: appWindow.monoFont.name
                            elide: Text.ElideRight
                        }

                        Button {
                            Layout.preferredWidth: 70
                            Layout.preferredHeight: 30
                            onClicked: {
                                if (varEditViewModel) {
                                    varEditViewModel.runFunction(modelData.name);
                                }
                            }

                            background: Rectangle {
                                radius: 6
                                color: appWindow.colorPrimary
                            }

                            contentItem: Text {
                                text: "RUN"
                                font.pixelSize: 10
                                font.bold: true
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: functionsList.count === 0
                text: serialState.connecting ? "Connessione in corso..." : "Connetti un dispositivo"
                font.pixelSize: 14
                color: appWindow.colorOnSurfaceVariant
                font.family: appWindow.monoFont.name
            }
        }
    }
}
