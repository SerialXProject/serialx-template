from PySide6.QtCore import QObject, Property, Signal, Slot
from pySerialX.serialx_python_integration import SerialX
from pySerialX.serialx_jit_interpreter import SerialXInterpreter

class VarEditViewModel(QObject):

    # Dynamic list
    variablesChanged = Signal()
    functionsChanged = Signal()
    serialConnectionStarted = Signal()
    serialConnectionFinished = Signal(bool, str)
    variableSent = Signal(str, bool, str)   # (name, success, message)
    functionRun = Signal(str, bool, str)    # (name, success, message)

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

    @Slot(str, str, str)
    def connectSerialAndLoadVariables(self, port, baudrate, ip_address=""):
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
