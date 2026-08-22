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
    color: colorSurface

    // --- Theme resolution ---
    // "Dark" / "Light" / "System" arrivano da settingsViewModel.theme (persistito con QSettings)
    readonly property bool isDark: {
        if (settingsViewModel.theme === "Dark") return true;
        if (settingsViewModel.theme === "Light") return false;
        return Qt.styleHints.colorScheme === Qt.Dark; // "System"
    }

    // --- Design Tokens (Dark palette) ---
    readonly property color darkPrimary: "#a3c9ff"
    readonly property color darkPrimaryContainer: "#0078d4"
    readonly property color darkSurface: "#131313"
    readonly property color darkSurfaceLow: "#1b1b1c"
    readonly property color darkSurfaceHigh: "#2a2a2a"
    readonly property color darkSurfaceHighest: "#353535"
    readonly property color darkOnSurface: "#e5e2e1"
    readonly property color darkOnSurfaceVariant: "#c0c7d4"
    readonly property color darkTertiary: "#ffb689"
    readonly property color darkError: "#ffb4ab"
    readonly property color darkWarn: "#f5a623"
    readonly property color darkOutline: "#3a3a3a"
    readonly property color darkOutlineVariant: "#404752"
    readonly property color darkOnPrimaryContainer: "#ffffff"

    // --- Design Tokens (Light palette) ---
    readonly property color lightPrimary: "#0058b0"
    readonly property color lightPrimaryContainer: "#a3c9ff"
    readonly property color lightSurface: "#fdfbff"
    readonly property color lightSurfaceLow: "#f5f5f7"
    readonly property color lightSurfaceHigh: "#e8e8ea"
    readonly property color lightSurfaceHighest: "#dcdce0"
    readonly property color lightOnSurface: "#1a1c1e"
    readonly property color lightOnSurfaceVariant: "#43474e"
    readonly property color lightTertiary: "#8f4c2e"
    readonly property color lightError: "#ba1a1a"
    readonly property color lightWarn: "#a15c00"
    readonly property color lightOutline: "#d0d0d4"
    readonly property color lightOutlineVariant: "#c4c8d0"
    readonly property color lightOnPrimaryContainer: "#001b3d"

    // --- Colori attivi: scelgono dark o light in base a isDark ---
    readonly property color colorPrimary: isDark ? darkPrimary : lightPrimary
    readonly property color colorPrimaryContainer: isDark ? darkPrimaryContainer : lightPrimaryContainer
    readonly property color colorSurface: isDark ? darkSurface : lightSurface
    readonly property color colorSurfaceLow: isDark ? darkSurfaceLow : lightSurfaceLow
    readonly property color colorSurfaceHigh: isDark ? darkSurfaceHigh : lightSurfaceHigh
    readonly property color colorSurfaceHighest: isDark ? darkSurfaceHighest : lightSurfaceHighest
    readonly property color colorOnSurface: isDark ? darkOnSurface : lightOnSurface
    readonly property color colorOnSurfaceVariant: isDark ? darkOnSurfaceVariant : lightOnSurfaceVariant
    readonly property color colorTertiary: isDark ? darkTertiary : lightTertiary
    readonly property color colorError: isDark ? darkError : lightError
    readonly property color colorWarn: isDark ? darkWarn : lightWarn
    readonly property color colorOutline: isDark ? darkOutline : lightOutline
    readonly property color outlineVariant: isDark ? darkOutlineVariant : lightOutlineVariant
    readonly property color colorOnPrimaryContainer: isDark ? darkOnPrimaryContainer : lightOnPrimaryContainer

    FontLoader {
        id: interFont
        source: "https://fonts.gstatic.com/s/inter/v13/UcCO3FwrK3iLTeHuS_fvQtMwCp50KnMw2boKoduKmMEVuLyfMZhrib2Bg-4.ttf"
    }

    FontLoader {
        id: monoFont
        source: "https://fonts.gstatic.com/s/roboto/v30/KFOjCnqEu92Fr1Mu51TzBhc9.ttf"
    }

    // ESPOSIZIONE FONT
    property alias interFont: interFont
    property alias monoFont: monoFont

    // ESPOSIZIONE STACK
    property alias stack: stack

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: "views/HomeView.qml"
    }
}
