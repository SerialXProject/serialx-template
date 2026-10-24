import threading

from PySide6.QtCore import QObject, Property, Signal, Slot, QSettings, QDateTime, QUrl
from PySide6.QtGui import QDesktopServices

from app import __appVersion__
from helpers.updates import check_for_updates, UpdateResult


class SettingsViewModel(QObject):

    themeChanged = Signal()
    lastCheckedChanged = Signal()
    checkingChanged = Signal()
    latestVersionChanged = Signal()
    updateCheckStarted = Signal()
    updateCheckFinished = Signal(bool, str)  # (update_available, message)

    _resultReady = Signal(object)  # uso interno: risultato dal thread

    def __init__(self):
        super().__init__()

        self._settings = QSettings("SerialXProject", "SerialXTemplate")
        self._theme = self._settings.value("theme", "System")
        self._last_checked = self._settings.value("last_checked", "")
        self._checking = False
        self._latest_version = ""
        self._release_url = ""

        self._resultReady.connect(self._on_result)

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

    # --- read-only da QML ---
    @Property(str, constant=True)
    def currentVersion(self):
        return __appVersion__

    @Property(str, notify=latestVersionChanged)
    def latestVersion(self):
        return self._latest_version

    @Property(bool, notify=checkingChanged)
    def checking(self):
        return self._checking

    def get_last_checked(self):
        return self._last_checked

    last_checked = Property(str, get_last_checked, notify=lastCheckedChanged)

    # --- azioni ---
    @Slot()
    def checkForUpdates(self):
        if self._checking:
            return
        self._checking = True
        self.checkingChanged.emit()
        self.updateCheckStarted.emit()

        def worker():
            self._resultReady.emit(check_for_updates())

        threading.Thread(target=worker, daemon=True).start()

    @Slot()
    def openReleasePage(self):
        if self._release_url:
            QDesktopServices.openUrl(QUrl(self._release_url))

    # --- risultato (eseguito nel thread principale) ---
    def _on_result(self, result: UpdateResult):
        self._checking = False
        self.checkingChanged.emit()

        if result.error:
            self.updateCheckFinished.emit(False, result.error)
            return

        self._release_url = result.release_url
        self._latest_version = result.latest_version
        self.latestVersionChanged.emit()

        now = QDateTime.currentDateTime().toString("hh:mm AP")
        self._last_checked = f"Last checked today at {now}."
        self._settings.setValue("last_checked", self._last_checked)
        self.lastCheckedChanged.emit()

        if result.update_available:
            message = f"Version {result.latest_version} is available (you have {__appVersion__})."
        else:
            message = "You are running the latest version."

        self.updateCheckFinished.emit(result.update_available, message)
