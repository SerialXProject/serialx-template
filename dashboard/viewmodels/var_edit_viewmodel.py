from PySide6.QtCore import QObject, Property, Signal, Slot
from PySide6.QtWidgets import QFileDialog
from pySerialX.serialx_python_integration import SerialX
from pySerialX.serialx_jit_interpreter import SerialXInterpreter
import json
import math

class VarEditViewModel(QObject):

    # Dynamic list
    variablesChanged = Signal()
    functionsChanged = Signal()
    serialConnectionStarted = Signal()
    serialConnectionFinished = Signal(bool, str)
    variableSent = Signal(str, bool, str)   # (name, success, message)
    functionRun = Signal(str, bool, str)    # (name, success, message)
    exportStarted = Signal()
    exportFinished = Signal(bool, str)
    importStarted = Signal()
    importFinished = Signal(bool, str)

    def __init__(self):
        super().__init__()
        self._variables = [] # {"name": str, "type": str, "value": str, "can_set": bool}
        self._functions = [] # {"name": str}

    def get_variables(self):
        return self._variables
    variables = Property("QVariantList", get_variables, notify=variablesChanged)

    def get_functions(self):
        return self._functions
    functions = Property("QVariantList", get_functions, notify=functionsChanged)

    @Slot(list, list)
    def loadVariables(self, variables, functions):
        self._variables = variables
        self._functions = functions
        self.variablesChanged.emit()
        self.functionsChanged.emit()

    @Slot(int, str)
    def updateVariableValue(self, index, value):
        if 0 <= index < len(self._variables):
            self._variables[index]["value"] = value
            self._variables[index]["imported"] = False

    @staticmethod
    def _coerce_import_value(variable_type, value):
        variable_type = variable_type.lower()
        if variable_type == "bool":
            if isinstance(value, bool):
                return value
            if type(value) is int and value in (0, 1):
                return bool(value)
            if isinstance(value, str):
                normalized = value.strip().lower()
                if normalized in ("true", "1"):
                    return True
                if normalized in ("false", "0"):
                    return False
            raise ValueError("Expected a boolean")

        if variable_type in ("int", "uint8_t", "uint16_t", "uint32_t", "long"):
            if type(value) is int:
                number = value
            elif isinstance(value, str):
                number = int(value)
            else:
                raise ValueError("Expected an integer")
            unsigned_limits = {"uint8_t": 255, "uint16_t": 65535, "uint32_t": 4294967295}
            if variable_type in unsigned_limits and not 0 <= number <= unsigned_limits[variable_type]:
                raise ValueError("Integer is outside the supported range")
            return number

        if variable_type in ("float", "double"):
            if isinstance(value, bool):
                raise ValueError("Expected a number")
            if isinstance(value, (int, float, str)):
                number = float(value)
                if math.isfinite(number):
                    return number
            raise ValueError("Expected a finite number")

        if variable_type in ("string", "charstring", "char"):
            if isinstance(value, str) and (variable_type != "char" or len(value) == 1):
                return value
            raise ValueError("Expected a compatible string")

        raise ValueError(f"Unsupported variable type: {variable_type}")

    @Slot(str, str, str)
    def connectDevice(self, port, baudrate, ip_address=""):
        """
        Connette serialmente e carica le variabili direttamente nel VarEditViewModel
        senza navigare a LoadingView.
        
        Args:
            port: porta seriale (es. "COM3" o "Net/Tcp")
            baudrate: baud rate (es. "115200" o "Net/Tcp")
            ip_address: indirizzo IP (solo per Net/Tcp)
        """
        self.serialConnectionStarted.emit()
        
        try:
            # Connessione seriale standard
            communication = SerialX(port, baudrate)
            self._communication = communication

            print(f"Connected to {port} at {baudrate} baud")

            communication.auth("secure")
            communication.communication.communication.send_line("help")
            result = SerialXInterpreter.decode_help(communication.communication._read_all_lines())
            
            variables_data = []
            for var in result['variables']:
                variables_data.append({
                    "name": var['name'],
                    "type": var['type'],
                    "value":  communication.get(var['type'], var['name'], var['is_virtual']),
                    "can_set": var['can_set']
                })
            
            functions_data = []
            for func_name in result['functions']:
                functions_data.append({"name": func_name})

            self.loadVariables(variables_data, functions_data)
            
            self.serialConnectionFinished.emit(True, f"Connected to {port} at {baudrate} baud")
                
        except Exception as e:
            self._communication = None  # Reset della connessione in caso di errore
            self.serialConnectionFinished.emit(False, f"Serial connection error: {str(e)}")

    # --- azioni ---
    @Slot(str, str, str)
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
            self.variableSent.emit(name, True, f"{name} updated to {value}")
            return result
        except Exception as e:
            print(f"Error during change value {name}: {str(e)}")
            self.variableSent.emit(name, False, f"Error updating {name}: {str(e)}")
            raise

    @Slot(str)
    def runFunction(self, name):
        """
        Esegue una funzione sul device Arduino.
        
        Args:
            name: nome della funzione da eseguire
        """
        try:
            if not self._communication:
                raise RuntimeError("No active serial connection")
            
            print(f"Running function: {name}")
            result = self._communication.run(name)
            print(f"Function result: {result}")
            self.functionRun.emit(name, True, f"{name} executed successfully")
            return result
        except Exception as e:
            print(f"Error running function {name}: {str(e)}")
            self.functionRun.emit(name, False, f"Error running {name}: {str(e)}")
            raise

    @Slot()
    def exportData(self):
        self.exportStarted.emit()
        try:
            file_path, _ = QFileDialog.getSaveFileName(None, "Export data", "export.json", "JSON Files (*.json)")
            if not file_path:
                self.exportFinished.emit(False, "Export cancelled")
                return
            data = {
                variable["name"]: variable["value"]
                for variable in self._variables
                if variable.get("can_set", False)
            }
            with open(file_path, "w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False, indent=4)
            self.exportFinished.emit(True, f"Exported to {file_path}")
        except Exception as e:
            self.exportFinished.emit(False, f"Export error: {str(e)}")

    @Slot()
    def importData(self):
        self.importStarted.emit()
        try:
            file_path, _ = QFileDialog.getOpenFileName(None, "Import data", "", "JSON Files (*.json)")
            if not file_path:
                self.importFinished.emit(False, "Import cancelled")
                return
            with open(file_path, "r", encoding="utf-8") as f:
                data = json.load(f)
            if not isinstance(data, dict):
                raise ValueError("JSON must contain an object of variable names and values")

            for variable in self._variables:
                variable["imported"] = False

            variables_by_name = {
                variable["name"]: variable
                for variable in self._variables
                if variable.get("can_set", False)
            }
            compatible_count = 0
            changed_count = 0
            for name, value in data.items():
                variable = variables_by_name.get(name)
                if variable is None:
                    continue
                try:
                    imported_value = self._coerce_import_value(variable["type"], value)
                except (TypeError, ValueError, OverflowError):
                    continue

                current_value = variable["value"]
                try:
                    current_value = self._coerce_import_value(variable["type"], current_value)
                except (TypeError, ValueError, OverflowError):
                    pass
                changed = imported_value != current_value
                variable["value"] = imported_value
                variable["imported"] = changed
                compatible_count += 1
                changed_count += changed

            self.variablesChanged.emit()
            skipped_count = len(data) - compatible_count
            self.importFinished.emit(
                True,
                f"Imported {compatible_count} compatible variables; changed {changed_count}; ignored {skipped_count} unknown or incompatible values from {file_path}",
            )
        except Exception as e:
            self.importFinished.emit(False, f"Import error: {str(e)}")
