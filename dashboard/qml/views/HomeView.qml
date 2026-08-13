import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components" as Widgets

Page {
    id: page

    // ...existing code...

    Widgets.ConnectionMenu {
        id: connectionMenu
        homeViewModel: homeViewModel
    }

    Rectangle {
        anchors.fill: parent
        color: appWindow.colorSurface   // oppure "#131313"
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
            color: "#131313"

            RowLayout {
                anchors.fill: parent
                spacing: 30

                Text {
                    text: "SerialXTemplate"
                    color: "#60a5fa"
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
                        width: 160
                        height: 50

                        background: Rectangle {
                            radius: 8
                            gradient: Gradient {
                                GradientStop {
                                    position: 0.0
                                    color: "#60a5fa"
                                }
                                GradientStop {
                                    position: 1.0
                                    color: "#1d4ed8"
                                }
                            }
                        }

                        contentItem: Text {
                            text: "IMPORT"
                            font.pixelSize: 12
                            font.bold: true
                            font.letterSpacing: 1
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            console.log("IMPORT clicked");
                        }
                    }

                    // EXPORT BUTTON
                    Button {
                        width: 160
                        height: 50

                        background: Rectangle {
                            radius: 8
                            gradient: Gradient {
                                GradientStop {
                                    position: 0.0
                                    color: "#60a5fa"
                                }
                                GradientStop {
                                    position: 1.0
                                    color: "#1d4ed8"
                                }
                            }
                        }

                        contentItem: Text {
                            text: "EXPORT"
                            font.pixelSize: 12
                            font.bold: true
                            font.letterSpacing: 1
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            console.log("EXPORT clicked");
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
                            model: ["COM1", "COM2", "COM3", "COM4"]

                            background: Rectangle {
                                color: "transparent"
                            }
                            indicator: Item {}

                            contentItem: Text {
                                text: portCombo.currentText
                                color: appWindow.colorPrimary
                                font.pixelSize: 14
                                font.family: appWindow.monoFont.name
                            }
                        }
                        Rectangle {
                            width: 1
                            height: 20
                            color: appWindow.colorOutline
                        }

                        Text {
                            text: "BAUD RATE"
                            font.pixelSize: 10
                            color: appWindow.colorOnSurfaceVariant
                            font.family: appWindow.monoFont.name
                        }

                        ComboBox {
                            id: baudCombo
                            model: ["9600", "19200", "38400", "57600", "115200"]

                            background: Rectangle {
                                color: "transparent"
                            }
                            indicator: Item {}

                            contentItem: Text {
                                text: baudCombo.currentText
                                color: appWindow.colorOnSurface
                                font.pixelSize: 14
                                font.family: appWindow.monoFont.name
                            }

                            delegate: ItemDelegate {
                                width: baudCombo.width
                                text: modelData

                                highlighted: baudCombo.highlightedIndex === index

                                background: Rectangle {
                                    radius: 6
                                    color: highlighted ? "#1d4ed8" : "transparent"
                                }

                                contentItem: Text {
                                    text: modelData
                                    color: highlighted ? "white" : appWindow.colorOnSurface
                                    font.family: appWindow.monoFont.name
                                }
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

                        background: Rectangle {
                            radius: 8
                            gradient: Gradient {
                                GradientStop {
                                    position: 0.0
                                    color: "#60a5fa"
                                }
                                GradientStop {
                                    position: 1.0
                                    color: "#1d4ed8"
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

                        onClicked: {
                            connectionMenu.open();
                        }
                    }
                }
            }
        }
    }
}
