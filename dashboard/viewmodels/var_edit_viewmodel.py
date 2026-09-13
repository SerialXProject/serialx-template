from PySide6.QtCore import QObject, Property, Signal, Slot


class VarEditViewModel(QObject):

    variablesChanged = Signal()
    functionsChanged = Signal()
    variableSent = Signal(str, bool, str)   # (name, success, message)
    functionRun = Signal(str, bool, str)    # (name, success, message)

    def __init__(self, home_viewmodel=None):
        super().__init__()

        # Ogni variabile: {"name": str, "type": str, "value": str}
        self._variables = []

        # Ogni funzione: {"name": str}
        self._functions = []
        
        # Riferimento al viewmodel home per eseguire funzioni
        self._home_viewmodel = home_viewmodel

    # --- variabili ---

    def get_variables(self):
        return self._variables

    variables = Property("QVariantList", get_variables, notify=variablesChanged)

    # --- funzioni ---

    def get_functions(self):
        return self._functions

    functions = Property("QVariantList", get_functions, notify=functionsChanged)

    # --- caricamento dinamico ---

    @Slot()
    def loadVariables(self):
        # TODO: sostituire con lettura reale (es. query al device via seriale)
        # Esempio placeholder:
        self._variables = [
            {"name": "TEMP_THRESHOLD", "type": "float", "value": "25.5"},
            {"name": "LED_MODE", "type": "int", "value": "1"},
            {"name": "DEVICE_NAME", "type": "string", "value": "Arduino_01"},
        ]
        self._functions = [
            {"name": "RESET_DEVICE"},
            {"name": "CALIBRATE_SENSOR"},
            {"name": "SAVE_CONFIG"},
        ]
        self.variablesChanged.emit()
        self.functionsChanged.emit()

    @Slot(list, list)
    def loadVariablesFromSerial(self, variables_data, functions_data):
        """
        Carica le variabili e funzioni da una connessione seriale.
        
        Args:
            variables_data: lista di dict con chiavi "name", "type", "value"
            functions_data: lista di dict con chiave "name"
        """
        self._variables = variables_data
        self._functions = functions_data
        self.variablesChanged.emit()
        self.functionsChanged.emit()

    # --- azioni ---

    @Slot(str, str)
    def sendVariable(self, name, value):
        # TODO: logica reale di invio al device (es. comando seriale)
        try:
            print(f"Sending {name} = {value}")
            # ... invio reale qui ...
            self.variableSent.emit(name, True, f"{name} updated to {value}")
        except Exception as e:
            self.variableSent.emit(name, False, f"Error updating {name}: {str(e)}")

    @Slot(str)
    def runFunction(self, name):
        """
        Esegue una funzione sul device Arduino.
        
        Args:
            name: nome della funzione da eseguire
        """
        try:
            print(f"Running function {name}")
            
            if self._home_viewmodel:
                result = self._home_viewmodel.runFunction(name)
                self.functionRun.emit(name, True, f"{name} executed successfully")
            else:
                raise RuntimeError("HomeViewModel not available")
                
        except Exception as e:
            self.functionRun.emit(name, False, f"Error running {name}: {str(e)}")