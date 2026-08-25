from pathlib import Path
import csv
import webbrowser

from PySide6.QtCore import QObject, Property, Signal, Slot, QTimer, QDateTime
from PySide6.QtWidgets import QFileDialog

import serial.tools.list_ports


class HomeViewModel(QObject):

    timeChanged = Signal()
    dateChanged = Signal()
    availablePortsChanged = Signal()
    exportStarted = Signal()
    exportFinished = Signal(bool, str)
    importStarted = Signal()
    importFinished = Signal(bool, str)

    def __init__(self):
        super().__init__()

        self._time = ""
        self._date = ""
        self._available_ports = []

        self.timer = QTimer(self)
        self.timer.timeout.connect(self._update)
        self.timer.start(1000)

        self._update()
        self.refreshPorts()

    def _update(self):
        now = QDateTime.currentDateTime()
        self._time = now.toString("hh:mm")
        self._date = now.toString("dd MMM yyyy").upper()
        self.timeChanged.emit()
        self.dateChanged.emit()

    def get_time(self):
        return self._time

    def get_date(self):
        return self._date

    time = Property(str, get_time, notify=timeChanged)
    date = Property(str, get_date, notify=dateChanged)

    # --- porte seriali ---

    def get_available_ports(self):
        return self._available_ports

    availablePorts = Property("QVariantList", get_available_ports, notify=availablePortsChanged)

    @Slot()
    def refreshPorts(self):
        ports = [p.device for p in serial.tools.list_ports.comports()]
        ports.append("NET(TCP)")

        if ports != self._available_ports:
            self._available_ports = ports
            self.availablePortsChanged.emit()

    # --- azioni esistenti ---

    @Slot()
    def openHelp(self):
        file_path = Path(__file__).resolve().parents[1] / "docs" / "index.html"
        webbrowser.open(f"file://{file_path}")

    @Slot()
    def exportData(self):
        self.exportStarted.emit()
        try:
            file_path, _ = QFileDialog.getSaveFileName(None, "Export data", "export.csv", "CSV Files (*.csv)")
            if not file_path:
                self.exportFinished.emit(False, "Export cancelled")
                return
            with open(file_path, "w", newline="", encoding="utf-8") as f:
                writer = csv.writer(f)
                writer.writerow(["Field1", "Field2", "Field3"])
                writer.writerow(["value1", "value2", "value3"])
            self.exportFinished.emit(True, f"Exported to {file_path}")
        except Exception as e:
            self.exportFinished.emit(False, f"Export error: {str(e)}")

    @Slot()
    def importData(self):
        self.importStarted.emit()
        try:
            file_path, _ = QFileDialog.getOpenFileName(None, "Import data", "", "CSV Files (*.csv)")
            if not file_path:
                self.importFinished.emit(False, "Import cancelled")
                return
            with open(file_path, "r", newline="", encoding="utf-8") as f:
                rows = list(csv.reader(f))
            self.importFinished.emit(True, f"Imported {len(rows)} rows from {file_path}")
        except Exception as e:
            self.importFinished.emit(False, f"Import error: {str(e)}")