from pathlib import Path
import csv
import webbrowser
import json
from pySerialX.serialx_python_integration import SerialX
from pySerialX.serialx_jit_interpreter import SerialXInterpreter

from PySide6.QtCore import QObject, Property, Signal, Slot, QTimer, QDateTime, QThread
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
    serialConnectionStarted = Signal()
    serialConnectionFinished = Signal(bool, str)  # (success, message)

    def __init__(self, var_edit_viewmodel=None):
        super().__init__()

        self._time = ""
        self._date = ""
        self._available_ports = []
        self._var_edit_viewmodel = var_edit_viewmodel
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

    # --- connessione seriale con caricamento variabili (per modalità edit) ---

    @Slot(str, str, str)
    def connectSerialAndLoadVariables(self, port, baudrate, ip_address=""):
        """
        Connette serialmente e carica le variabili direttamente nel VarEditViewModel
        senza navigare a LoadingView.
        
        Args:
            port: porta seriale (es. "COM3" o "NET(TCP)")
            baudrate: baud rate (es. "115200" o "Net/Tcp")
            ip_address: indirizzo IP (solo per NET(TCP))
        """
        self.serialConnectionStarted.emit()
        
        try:
            # Connessione seriale standard
            communication = SerialX(port, baudrate)
            self._communication = communication  # Salva la connessione per uso successivo

            print(f"Connected to {port} at {baudrate} baud")

            communication.auth("secure")
            communication.communication.communication.send_line("help")
            result = SerialXInterpreter.decode_help(communication.communication._read_all_lines())

            print(result)
            
            # Trasformare i dati nel formato atteso dal VarEditViewModel
            variables_for_viewmodel = []
            for var in result['variables']:
                variables_for_viewmodel.append({
                    "name": var['name'],
                    "type": var['type'],
                    "value":  communication.get(var['type'], var['name'], var['is_virtual']),
                    "can_set": var['can_set']
                })
            
            functions_for_viewmodel = []
            for func_name in result['functions']:
                functions_for_viewmodel.append({"name": func_name})

            # Caricamenti i dati nel viewmodel delle variabili
            if self._var_edit_viewmodel:
                self._var_edit_viewmodel.loadVariablesFromSerial(variables_for_viewmodel, functions_for_viewmodel)
            
            self.serialConnectionFinished.emit(True, f"Connected to {port} at {baudrate} baud")
                
        except Exception as e:
            self._communication = None  # Reset della connessione in caso di errore
            self.serialConnectionFinished.emit(False, f"Serial connection error: {str(e)}")

    @Slot(str)
    def runFunction(self, function_name):
        """
        Esegue una funzione sul device Arduino.
        
        Args:
            function_name: nome della funzione da eseguire
        """
        try:
            if not self._communication:
                raise RuntimeError("No active serial connection")
            
            print(f"Running function: {function_name}")
            result = self._communication.run(function_name)
            print(f"Function result: {result}")
            return result
        except Exception as e:
            print(f"Error running function {function_name}: {str(e)}")
            raise

    @Slot(str)
    def setVariable(self, type, name, value):
        """
        Modifica una variabile sul device Arduino.
        
        Args:
            tipo: tipo di dato della variabile (es. "int", "float", "bool", "string")
            name: nome della variabile
            value: nuovo valore della variabile
        """
        try:
            if not self._communication:
                raise RuntimeError("No active serial connection")
            
            print(f"Change value: {name} di type {type} a {value}")
            result = self._communication.set(type, name, value)
            print(f"Function result: {result}")
            return result
        except Exception as e:
            print(f"Error during change value {name}: {str(e)}")
            raise

