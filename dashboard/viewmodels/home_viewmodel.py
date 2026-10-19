from pathlib import Path
import helpers.script_generator as script_generator
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

    connectionModeSelected = Signal(str)

    def __init__(self):
        super().__init__()

        self._time = ""
        self._date = ""
        self._available_ports = []
        self._communication = None  # Salva l'oggetto di connessione seriale

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

    def get_available_ports(self):
        return self._available_ports

    availablePorts = Property("QVariantList", get_available_ports, notify=availablePortsChanged)

    @Slot()
    def refreshPorts(self):
        ports = [p.device for p in serial.tools.list_ports.comports()]
        ports.append("Net/Tcp")

        if ports != self._available_ports:
            self._available_ports = ports
            self.availablePortsChanged.emit()

    @Slot()
    def openHelp(self):
        file_path = Path(__file__).resolve().parents[1] / "docs" / "index.html"
        webbrowser.open(f"file://{file_path}")

    @Slot()
    def selectSerialXConnection(self):
        print("Connessione SerialX (Nativa) selezionata")
        self.connectionMode = "serialx"
        self.connectionModeSelected.emit("serialx")
        script = script_generator.generate_serialx_script(None)  # Placeholder for actual data
        if script is not None:
            print("✓ SerialX script generated successfully!")
        else:
            print("✗ Failed to generate SerialX script.")

    @Slot()
    def selectPythonConnection(self):
        print("Connessione Python (Consigliata) selezionata")
        self.connectionMode = "python"
        self.connectionModeSelected.emit("python")
        script = script_generator.generate_python_script(None)  # Placeholder for actual data
        if script is not None:
            print("✓ Python script generated successfully!")
        else:
            print("✗ Failed to generate Python script.")
