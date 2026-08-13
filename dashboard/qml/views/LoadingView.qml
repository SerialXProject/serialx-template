import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components" as Widgets

Page {
    id: window
    visible: true
    title: "Technical Atelier - System Node"

    Rectangle {
        anchors.fill: parent
        color: appWindow.colorSurface
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            height: 56
            color: appWindow.colorSurfaceLow
            border.color: appWindow.colorOutline

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 24
                anchors.rightMargin: 24
                spacing: 16

                Text {
                    text: "SerialX Projects"
                    color: appWindow.colorOnSurface
                    font.pixelSize: 18
                    font.bold: true
                    font.letterSpacing: -0.5
                }

                Rectangle {
                    width: 1
                    height: 16
                    color: appWindow.colorOutlineVariant
                }

                Text {
                    text: "SerialX"
                    color: appWindow.colorPrimary
                    font.family: "JetBrains Mono"
                    font.pixelSize: 12
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }

        // Main Content
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 48
                spacing: 32

                // Status Section
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        Column {
                            spacing: 4
                            Text {
                                text: "STATUS"
                                color: appWindow.colorPrimary
                                font.pixelSize: 12
                                font.bold: true
                                font.letterSpacing: 2
                            }
                            Text {
                                text: "Serial Communication..."
                                color: appWindow.colorOnSurface
                                font.pixelSize: 32
                            }
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        Text {
                            text: Math.floor(loadingViewModel.progress) + "%"
                            color: appWindow.colorOnSurfaceVariant
                            font.family: "JetBrains Mono"
                            font.pixelSize: 40
                            font.bold: true
                        }
                    }

                    // Progress Bar
                    Rectangle {
                        Layout.fillWidth: true
                        height: 16
                        radius: 8
                        color: appWindow.colorSurfaceHighest
                        clip: true

                        Rectangle {
                            width: parent.width * (loadingViewModel.progress / 100)
                            height: parent.height
                            radius: 8
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop {
                                    position: 0.0
                                    color: appWindow.colorPrimary
                                }
                                GradientStop {
                                    position: 1.0
                                    color: appWindow.colorPrimaryContainer
                                }
                            }

                            // Scanning highlight simulation
                            Rectangle {
                                width: 100
                                height: parent.height
                                x: -100 + (progressAnim.value * (parent.width + 200))
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop {
                                        position: 0.0
                                        color: "transparent"
                                    }
                                    GradientStop {
                                        position: 0.5
                                        color: Qt.rgba(1, 1, 1, 0.2)
                                    }
                                    GradientStop {
                                        position: 1.0
                                        color: "transparent"
                                    }
                                }
                                rotation: -15

                                NumberAnimation on x {
                                    id: progressAnim
                                    from: 0
                                    to: 1
                                    duration: 2000
                                    loops: Animation.Infinite
                                    property real value: 0
                                }
                            }
                        }
                    }
                }

                // Log Container
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: appWindow.colorSurface
                    radius: 12
                    border.color: appWindow.colorOutline
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        // Log Header
                        Rectangle {
                            Layout.fillWidth: true
                            height: 48
                            color: appWindow.colorSurfaceLow
                            radius: 12

                            // Mask bottom corners
                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: 12
                                color: appWindow.colorSurfaceLow
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 24
                                anchors.rightMargin: 24
                                spacing: 12

                                Text {
                                    text: "EXECUTION LOG"
                                    color: appWindow.colorOnSurfaceVariant
                                    font.pixelSize: 11
                                    font.bold: true
                                    font.letterSpacing: 1.5
                                }
                                Item {
                                    Layout.fillWidth: true
                                }
                                Row {
                                    spacing: 8
                                    Rectangle {
                                        width: 10
                                        height: 10
                                        radius: 5
                                        color: Qt.rgba(1, 0.7, 0.6, 0.2)
                                        border.color: Qt.rgba(1, 0.7, 0.6, 0.4)
                                    }
                                    Rectangle {
                                        width: 10
                                        height: 10
                                        radius: 5
                                        color: Qt.rgba(1, 0.7, 0.5, 0.2)
                                        border.color: Qt.rgba(1, 0.7, 0.5, 0.4)
                                    }
                                    Rectangle {
                                        width: 10
                                        height: 10
                                        radius: 5
                                        color: Qt.rgba(0.6, 0.8, 1, 0.2)
                                        border.color: Qt.rgba(0.6, 0.8, 1, 0.4)
                                    }
                                }
                            }
                        }

                        // Log Content
                        ListView {
                            id: logView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            model: loadingViewModel.logs
                            clip: true
                            delegate: RowLayout {
                                width: logView.width
                                spacing: 12
                                Text {
                                    text: "[" + modelData.time + "]"
                                    color: appWindow.colorOnSurfaceVariant
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 13
                                }
                                Text {
                                    text: modelData.level + ":"
                                    color: modelData.level === "INFO" ? appWindow.colorPrimary : modelData.level === "WARN" ? appWindow.colorWarn : modelData.level === "ERROR" ? appWindow.colorError : appWindow.colorOnSurfaceVariant
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                                Text {
                                    text: modelData.msg
                                    color: appWindow.colorOnSurface
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 13
                                    Layout.fillWidth: true
                                    wrapMode: Text.Wrap
                                }
                            }
                            onCountChanged: logView.positionViewAtEnd()
                        }
                    }
                }

                // Action Footer
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 24

                    Column {
                        Text {
                            text: "SYSTEM LOAD"
                            color: appWindow.colorOnSurfaceVariant
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1
                        }
                        Text {
                            text: loadingViewModel.systemLoad
                            color: appWindow.colorOnSurface
                            font.family: "JetBrains Mono"
                            font.pixelSize: 12
                        }
                    }

                    Rectangle {
                        width: 1
                        height: 32
                        color: appWindow.colorOutlineVariant
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Button {
                        id: cancelButton

                        background: Rectangle {
                            implicitWidth: 180
                            implicitHeight: 44

                            radius: 8

                            color: cancelButton.hovered ? Qt.rgba(0.58, 0, 0.04, 0.2) : Qt.rgba(0.18, 0.28, 0.42, 0.3)

                            border.color: cancelButton.hovered ? Qt.rgba(1, 0.7, 0.6, 0.2) : "transparent"
                        }

                        contentItem: Item {
                            anchors.fill: parent

                            Row {
                                anchors.centerIn: parent
                                spacing: 8

                                Text {
                                    text: "✕ Cancel Operation"
                                    font.bold: true

                                    color: cancelButton.hovered ? appWindow.colorError : appWindow.colorOnSurfaceVariant
                                }
                            }
                        }

                        onClicked: {
                            appWindow.stack.pop();
                        }
                    }
                }
            }
        }

        // Footer
        Rectangle {
            Layout.fillWidth: true
            height: 32
            color: appWindow.colorSurfaceLow

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 24
                anchors.rightMargin: 24

                Text {
                    text: "V2.4.0 TECHNICAL ATELIER"
                    color: appWindow.colorOnSurfaceVariant
                    font.family: "JetBrains Mono"
                    font.pixelSize: 10
                    font.letterSpacing: 1
                }

                Item {
                    Layout.fillWidth: true
                }

                Row {
                    spacing: 24
                    Row {
                        spacing: 8
                        Rectangle {
                            width: 6
                            height: 6
                            radius: 3
                            color: "#10b981"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "CONNECTION: STABLE"
                            color: appWindow.colorPrimary
                            font.family: "JetBrains Mono"
                            font.pixelSize: 10
                            font.letterSpacing: 1
                        }
                    }
                    Text {
                        text: "LATENCY: 24MS"
                        color: appWindow.colorOnSurfaceVariant
                        font.family: "JetBrains Mono"
                        font.pixelSize: 10
                        font.letterSpacing: 1
                    }
                }
            }
        }
    }
}
