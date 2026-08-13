from PySide6.QtCore import QObject, Property, Signal, Slot, QSettings, QDateTime


class SettingsViewModel(QObject):

    themeChanged = Signal()
    currentVersionChanged = Signal()
    lastCheckedChanged = Signal()
    updateCheckStarted = Signal()
    updateCheckFinished = Signal(bool, str)  # (update_available, message)

    def __init__(self):
        super().__init__()

        self._settings = QSettings("SerialXProject", "SerialXTemplate")

        self._theme = self._settings.value("theme", "System")
        self._current_version = "v2.4.0-stable"
        self._last_checked = self._settings.value("last_checked", "")

    # --- theme ---

    def get_theme(self):
        return self._theme

    def set_theme(self, value):
        if self._theme == value:
            return
        self._theme = value
        self._settings.setValue("theme", value)
        self.themeChanged.emit()

    theme = Property(str, get_theme, set_theme, notify=themeChanged)

    # --- version / last check (read-only da QML) ---

    def get_current_version(self):
        return self._current_version

    current_version = Property(str, get_current_version, notify=currentVersionChanged)

    def get_last_checked(self):
        return self._last_checked

    last_checked = Property(str, get_last_checked, notify=lastCheckedChanged)

    # --- azioni ---

    @Slot()
    def checkForUpdates(self):
        self.updateCheckStarted.emit()

        # TODO: sostituire con chiamata reale (es. GitHub releases API)
        # Per ora è un placeholder: nessun aggiornamento trovato.
        update_available = False
        message = "You are running the latest version."

        now = QDateTime.currentDateTime().toString("hh:mm AP")
        self._last_checked = f"Last checked today at {now}."
        self._settings.setValue("last_checked", self._last_checked)
        self.lastCheckedChanged.emit()

        self.updateCheckFinished.emit(update_available, message)