import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components" as Widgets

Page {
    visible: true

    Rectangle {
        anchors.fill: parent
        color: appWindow.colorSurface
    }

    // --- Header ---
    Rectangle {
        id: topBar
        width: parent.width
        height: 64
        color: appWindow.colorSurface
        z: 10

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 32
            anchors.rightMargin: 32
            spacing: 12

            Button {
                text: "<--"
                font.family: "Material Symbols Outlined"

                Layout.alignment: Qt.AlignLeft

                onClicked: {
                    appWindow.stack.pop();
                }

                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: appWindow.colorPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 20
                    color: "transparent"
                    border.color: appWindow.colorPrimary
                    border.width: 1
                    opacity: parent.hovered ? 0.1 : 0
                }
            }

            Text {
                text: "Settings"
                color: appWindow.colorPrimary
                font.pixelSize: 20
                font.weight: Font.Bold
                font.letterSpacing: -0.5

                Layout.alignment: Qt.AlignLeft
            }

            Item {
                Layout.fillWidth: true
            }
        }
    }

    Flickable {
        anchors.top: topBar.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        contentHeight: mainLayout.height + 100
        clip: true

        ColumnLayout {
            id: mainLayout
            width: Math.min(parent.width - 128, 1000)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 48
            spacing: 40

            // --- Breadcrumb & Title ---
            ColumnLayout {
                spacing: 8
                Text {
                    text: "SerialX"
                    color: appWindow.colorPrimary
                    font.pixelSize: 48
                    font.weight: Font.Normal
                    font.letterSpacing: -1
                }
                Text {
                    text: "SerialX is a development language and tool for comunication for Arduino"
                    color: appWindow.colorOnSurfaceVariant
                    Layout.preferredWidth: 600
                    wrapMode: Text.WordWrap
                }
            }

            // --- Main Content Grid ---
            GridLayout {
                columns: 12
                columnSpacing: 40
                Layout.fillWidth: true

                // --- LEFT COLUMN (8 cols) ---
                ColumnLayout {
                    Layout.columnSpan: 8
                    Layout.fillWidth: true
                    spacing: 48

                    Text {
                        text: "Themes"
                        color: appWindow.colorPrimary
                        font.pixelSize: 24
                        font.bold: true
                    }

                    RowLayout {
                        spacing: 16
                        Layout.fillWidth: true

                        Widgets.ThemeCard {
                            label: "Dark"
                            active: settingsViewModel.theme === "Dark"
                            previewColor: "#121212"

                            Layout.fillWidth: true

                            onClicked: {
                                settingsViewModel.theme = "Dark";
                            }
                        }

                        Widgets.ThemeCard {
                            label: "Light"
                            active: settingsViewModel.theme === "Light"
                            previewColor: "#FFFFFF"

                            Layout.fillWidth: true

                            onClicked: {
                                settingsViewModel.theme = "Light";
                            }
                        }

                        Widgets.ThemeCard {
                            label: "System"
                            active: settingsViewModel.theme === "System"
                            isGradient: true

                            Layout.fillWidth: true

                            onClicked: {
                                settingsViewModel.theme = "System";
                            }
                        }
                    }
                }

                // --- RIGHT COLUMN (4 cols) ---
                ColumnLayout {
                    Layout.columnSpan: 4
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    spacing: 32

                    // Card: Software Updates
                    Rectangle {
                        Layout.fillWidth: true
                        height: 380
                        width: 250
                        color: appWindow.colorSurfaceHigh
                        radius: 16
                        clip: true

                        // Cerchio decorativo (blur simulato con opacità)
                        Rectangle {
                            width: 120
                            height: 120
                            radius: 60
                            color: appWindow.colorPrimary
                            opacity: 0.1
                            x: parent.width - 60
                            y: -60
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 28
                            spacing: 0

                            Text {
                                text: "Software Updates"
                                color: appWindow.colorPrimary
                                font.pixelSize: 18
                                font.weight: Font.Bold
                            }

                            Item {
                                Layout.preferredHeight: 32
                            }

                            Text {
                                text: "CURRENT VERSION"
                                color: appWindow.colorOnSurfaceVariant
                                font.pixelSize: 10
                                font.letterSpacing: 1.5
                            }
                            Text {
                                text: settingsViewModel.current_version
                                color: appWindow.colorPrimary
                                font.pixelSize: 28
                                font.family: stack.monoFont
                                font.weight: Font.Bold
                            }

                            Item {
                                Layout.preferredHeight: 24
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 60
                                color: appWindow.colorSurface
                                radius: 8
                                border.color: Qt.rgba(163 / 255, 201 / 255, 255 / 255, 0.2)
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 10
                                    Text {
                                        text: "info"
                                        font.family: "Material Symbols Outlined"
                                        color: appWindow.colorPrimary
                                        font.pixelSize: 18
                                    }
                                    Text {
                                        text: settingsViewModel.last_checked !== ""
                                              ? settingsViewModel.last_checked
                                              : "Not checked yet."
                                        color: appWindow.colorOnSurfaceVariant
                                        font.pixelSize: 11
                                        Layout.fillWidth: true
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }

                            Item {
                                Layout.fillHeight: true
                            }

                            QtObject {
                                id: updateState
                                property bool checking: false
                            }

                            Connections {
                                target: settingsViewModel
                                function onUpdateCheckStarted() {
                                    updateState.checking = true;
                                }
                                function onUpdateCheckFinished(updateAvailable, message) {
                                    updateState.checking = false;
                                }
                            }

                            Button {
                                id: updateBtn
                                Layout.fillWidth: true
                                enabled: !updateState.checking

                                onClicked: {
                                    settingsViewModel.checkForUpdates();
                                }

                                contentItem: RowLayout {
                                    spacing: 8
                                    Item {
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        text: updateState.checking ? "Checking..." : "Check for updates"
                                        color: "white"
                                        font.weight: Font.Bold
                                        font.pixelSize: 14
                                    }
                                    Image {
                                        source: Qt.resolvedUrl("../../assets/refresh-ccw.svg")
                                        width: 18
                                        height: 18
                                        sourceSize: Qt.size(18, 18)
                                        RotationAnimation on rotation {
                                            running: updateState.checking
                                            loops: Animation.Infinite
                                            from: 0
                                            to: 360
                                            duration: 800
                                        }
                                    }
                                    Item {
                                        Layout.fillWidth: true
                                    }
                                }
                                background: Rectangle {
                                    implicitHeight: 52
                                    radius: 8
                                    gradient: Gradient {
                                        orientation: Gradient.Horizontal
                                        GradientStop {
                                            position: 0
                                            color: "#a3c9ff"
                                        }
                                        GradientStop {
                                            position: 1
                                            color: "#0078d4"
                                        }
                                    }
                                    opacity: updateBtn.pressed ? 0.9 : (updateState.checking ? 0.7 : 1.0)
                                    scale: updateBtn.pressed ? 0.98 : 1.0
                                    Behavior on scale {
                                        NumberAnimation {
                                            duration: 50
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
