import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root
    spacing: 30

    Connections {
        target: varEditViewModel
        function onVariableSent(name, success, message) {
            console.log(message);
        }
        function onFunctionRun(name, success, message) {
            console.log(message);
        }
    }

    Component.onCompleted: {
        varEditViewModel.loadVariables();
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
            height: 1
            color: appWindow.colorOutline
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: varEditViewModel.variables

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
                        color: appWindow.colorOnSurface
                        font.pixelSize: 12
                        font.family: appWindow.monoFont.name
                        selectByMouse: true

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
                        onClicked: {
                            varEditViewModel.sendVariable(modelData.name, valueField.text);
                        }

                        background: Rectangle {
                            radius: 6
                            color: appWindow.colorPrimary
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
    }

    // Divisore verticale
    Rectangle {
        Layout.fillHeight: true
        width: 1
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
            height: 1
            color: appWindow.colorOutline
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: varEditViewModel.functions

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
                            varEditViewModel.runFunction(modelData.name);
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
    }
}
