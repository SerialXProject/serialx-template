import "../components" as Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: page

    // --- Export / Import state ---
    QtObject {
        id: exportState
        property bool exporting: false
    }

    QtObject {
        id: importState
        property bool importing: false
    }

    // --- Content panel state ---
    QtObject {
        id: contentState
        property string activeMode: "" // "" = vuoto, "var_edit" = editor variabili
    }

    Connections {
        target: homeViewModel
        function onExportStarted() {
            exportState.exporting = true;
        }
        function onExportFinished(success, message) {
            exportState.exporting = false;
            console.log(message);
        }
        function onImportStarted() {
            importState.importing = true;
        }
        function onImportFinished(success, message) {
            importState.importing = false;
            console.log(message);
        }
    }

    Widgets.ConnectionMenu {
        id: connectionMenu

        homeViewModel: homeViewModel
    }

    Rectangle {
        anchors.fill: parent
        color: appWindow.colorSurface
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        anchors.leftMargin: 40
        anchors.rightMargin: 40

        // --- Header ---
        Rectangle {
            Layout.fillWidth: true
            height: 70
            color: appWindow.colorSurface

            RowLayout {
                anchors.fill: parent
                spacing: 30

                Text {
                    text: "SerialXTemplate"
                    color: appWindow.colorPrimary
                    font.pixelSize: 20
                    font.weight: Font.Bold
                    font.family: appWindow.interFont.name
                }

                Item {
                    Layout.fillWidth: true
                }

                Row {
                    spacing: 20

                    Text {
                        text: "editor"
                        font.pixelSize: 24
                        color: contentState.activeMode === "var_edit" ? appWindow.colorPrimary : appWindow.colorOnSurfaceVariant
                        font.family: "Material Symbols Outlined"

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                contentState.activeMode = contentState.activeMode === "var_edit" ? "" : "var_edit";
                            }
                        }

                    }

                    Text {
                        text: "settings"
                        font.pixelSize: 24
                        color: appWindow.colorOnSurfaceVariant
                        font.family: "Material Symbols Outlined"

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                appWindow.stack.push(Qt.resolvedUrl("SettingsView.qml"));
                            }
                        }

                    }

                    Text {
                        text: "help"
                        font.pixelSize: 24
                        color: appWindow.colorOnSurfaceVariant
                        font.family: "Material Symbols Outlined"

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                homeViewModel.openHelp();
                            }
                        }

                    }

                }

            }

        }

        // Title Area
        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 20

            Column {
                Text {
                    text: "SerialXProject"
                    font.pixelSize: 48
                    font.weight: Font.Black
                    color: appWindow.colorOnSurface
                    font.family: appWindow.interFont.name
                }

                Text {
                    text: "Arduino SerialX - Desktop Client Template"
                    font.pixelSize: 12
                    font.letterSpacing: 2
                    color: appWindow.colorOnSurfaceVariant
                    font.family: appWindow.interFont.name
                }

            }

            Item {
                Layout.fillWidth: true
            }

            Row {
                spacing: 15

                Widgets.SystemCard {
                    id: systemTime

                    title: "SYSTEM TIME"
                    value: homeViewModel.time
                    isTime: true
                }

                Widgets.SystemCard {
                    id: systemDate

                    title: "SYSTEM DATE"
                    value: homeViewModel.date
                    isTime: false
                }

            }

        }

        // --- Main Content ---
        ColumnLayout {
            width: parent.width
            spacing: 40

            // Cards Grid
            RowLayout {
                Layout.fillWidth: true
                spacing: 30

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumWidth: 300
                    Layout.minimumHeight: 450
                    Layout.preferredWidth: 1000
                    color: appWindow.colorSurfaceLow
                    radius: 8

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 30
                        spacing: 20

                        Loader {
                            id: contentLoader
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            source: contentState.activeMode === "var_edit" ? Qt.resolvedUrl("VarEditView.qml") : ""
                        }

                    }

                }

            }

        }

        // --- Footer ---
        Rectangle {
            Layout.fillWidth: true
            height: 100
            color: appWindow.colorSurface

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 40
                anchors.rightMargin: 40
                anchors.bottomMargin: 20
                anchors.topMargin: 20
                spacing: 20

                // Left buttons
                Row {
                    spacing: 15

                    // IMPORT BUTTON
                    Button {
                        id: importBtn

                        width: 160
                        height: 50
                        enabled: !importState.importing
                        onClicked: {
                            homeViewModel.importData();
                        }

                        background: Rectangle {
                            radius: 8
                            opacity: importBtn.pressed ? 0.9 : (importState.importing ? 0.7 : 1)

                            gradient: Gradient {
                                GradientStop {
                                    position: 0
                                    color: appWindow.colorPrimary
                                }

                                GradientStop {
                                    position: 1
                                    color: appWindow.colorPrimaryContainer
                                }

                            }

                        }

                        contentItem: Text {
                            text: importState.importing ? "IMPORTING..." : "IMPORT"
                            font.pixelSize: 12
                            font.bold: true
                            font.letterSpacing: 1
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                    }

                    // EXPORT BUTTON
                    Button {
                        id: exportBtn

                        width: 160
                        height: 50
                        enabled: !exportState.exporting
                        onClicked: {
                            homeViewModel.exportData();
                        }

                        background: Rectangle {
                            radius: 8
                            opacity: exportBtn.pressed ? 0.9 : (exportState.exporting ? 0.7 : 1)

                            gradient: Gradient {
                                GradientStop {
                                    position: 0
                                    color: appWindow.colorPrimary
                                }

                                GradientStop {
                                    position: 1
                                    color: appWindow.colorPrimaryContainer
                                }

                            }

                        }

                        contentItem: Text {
                            text: exportState.exporting ? "EXPORTING..." : "EXPORT"
                            font.pixelSize: 12
                            font.bold: true
                            font.letterSpacing: 1
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                    }

                }

                Item {
                    Layout.fillWidth: true
                }

                // Port Settings
                Rectangle {
                    height: 50
                    width: 300
                    color: appWindow.colorSurface
                    radius: 10
                    border.color: appWindow.colorOutline

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10

                        Text {
                            text: "PORT"
                            font.pixelSize: 10
                            color: appWindow.colorOnSurfaceVariant
                            font.family: appWindow.monoFont.name
                        }

                        ComboBox {
                            id: portCombo

                            model: homeViewModel.availablePorts
                            popup.width: 90

                            popup.background: Rectangle {
                                color: appWindow.colorSurfaceHigh
                                radius: 8
                                border.color: appWindow.colorOutline
                                border.width: 1
                            }

                            background: Rectangle {
                                color: "transparent"
                            }

                            indicator: Item {
                            }

                            contentItem: Text {
                                text: portCombo.currentText
                                color: appWindow.colorOnSurface
                                font.pixelSize: 14
                                font.family: appWindow.monoFont.name
                            }

                            delegate: ItemDelegate {
                                width: portCombo.popup.width
                                text: modelData
                                highlighted: portCombo.highlightedIndex === index

                                background: Rectangle {
                                    radius: 6
                                    color: highlighted ? appWindow.colorPrimaryContainer : "transparent"
                                }

                                contentItem: Text {
                                    text: modelData
                                    color: highlighted ? appWindow.colorOnPrimaryContainer : appWindow.colorOnSurface
                                    font.family: appWindow.monoFont.name
                                }

                            }

                        }

                        Rectangle {
                            width: 1
                            height: 20
                            color: appWindow.colorOutline
                        }

                        Text {
                            text: portCombo.currentText === "NET(TCP)" ? "IP ADDRESS" : "BAUD RATE"
                            font.pixelSize: 10
                            color: appWindow.colorOnSurfaceVariant
                            font.family: appWindow.monoFont.name
                        }

                        ComboBox {
                            id: baudCombo

                            visible: portCombo.currentText !== "NET(TCP)"
                            popup.width: 75
                            model: ["9600", "19200", "38400", "57600", "115200"]

                            popup.background: Rectangle {
                                color: appWindow.colorSurfaceHigh
                                radius: 8
                                border.color: appWindow.colorOutline
                                border.width: 1
                            }

                            background: Rectangle {
                                color: "transparent"
                            }

                            indicator: Item {
                            }

                            contentItem: Text {
                                text: baudCombo.currentText
                                color: appWindow.colorOnSurface
                                font.pixelSize: 14
                                font.family: appWindow.monoFont.name
                            }

                            delegate: ItemDelegate {
                                width: baudCombo.popup.width
                                text: modelData
                                highlighted: baudCombo.highlightedIndex === index

                                background: Rectangle {
                                    radius: 6
                                    color: highlighted ? appWindow.colorPrimaryContainer : "transparent"
                                }

                                contentItem: Text {
                                    text: modelData
                                    color: highlighted ? appWindow.colorOnSurface : appWindow.colorOnSurface
                                    font.family: appWindow.monoFont.name
                                }

                            }

                        }

                        TextField {
                            id: ipField

                            visible: portCombo.currentText === "NET(TCP)"
                            Layout.fillWidth: true
                            placeholderText: "192.168.1.100"
                            color: appWindow.colorOnSurface
                            font.pixelSize: 14
                            font.family: appWindow.monoFont.name
                            selectByMouse: true

                            background: Rectangle {
                                color: "transparent"
                            }

                            validator: RegularExpressionValidator {
                                regularExpression: /^(\d{1,3}\.){0,3}\d{0,3}$/
                            }
                        }

                    }

                }

                Row {
                    spacing: 15

                    // CONNECT BUTTON
                    Button {
                        width: 160
                        height: 50
                        onClicked: {
                            connectionMenu.open();
                        }

                        background: Rectangle {
                            radius: 8

                            gradient: Gradient {
                                GradientStop {
                                    position: 0
                                    color: appWindow.colorPrimary
                                }

                                GradientStop {
                                    position: 1
                                    color: appWindow.colorPrimaryContainer
                                }

                            }

                        }

                        contentItem: Text {
                            text: "CONNECT"
                            font.pixelSize: 12
                            font.bold: true
                            font.letterSpacing: 1
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                    }

                }

            }

        }

    }

}
