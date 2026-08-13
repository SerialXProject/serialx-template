import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: appWindow

    visible: true
    width: 1280
    height: 800
    minimumWidth: 1000
    minimumHeight: 800
    title: "SerialXTemplate - Arduino Client"
    color: "#131313"

    // --- Design Tokens ---
    readonly property color colorPrimary: "#a3c9ff"
    readonly property color colorPrimaryContainer: "#0078d4"
    readonly property color colorSurface: "#131313"
    readonly property color colorSurfaceLow: "#1b1b1c"
    readonly property color colorSurfaceHigh: "#2a2a2a"
    readonly property color colorSurfaceHighest: "#353535"
    readonly property color colorOnSurface: "#e5e2e1"
    readonly property color colorOnSurfaceVariant: "#c0c7d4"
    readonly property color colorTertiary: "#ffb689"
    readonly property color colorError: "#ffb4ab"
    readonly property color colorOutline: "#3a3a3a"
    readonly property color outlineVariant: "#404752"

    FontLoader {
        id: interFont
        source: "https://fonts.gstatic.com/s/inter/v13/UcCO3FwrK3iLTeHuS_fvQtMwCp50KnMw2boKoduKmMEVuLyfMZhrib2Bg-4.ttf"
    }

    FontLoader {
        id: monoFont
        source: "https://fonts.gstatic.com/s/roboto/v30/KFOjCnqEu92Fr1Mu51TzBhc9.ttf"
    }

    // ✅ ESPOSIZIONE FONT
    property alias interFont: interFont
    property alias monoFont: monoFont

    // ✅ ESPOSIZIONE STACK
    property alias stack: stack

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: "views/HomeView.qml"
    }
}
