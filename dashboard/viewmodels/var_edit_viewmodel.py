from PySide6.QtCore import QObject, Property, Signal, Slot


class VarEditViewModel(QObject):

    variablesChanged = Signal()
    functionsChanged = Signal()
    variableSent = Signal(str, bool, str)   # (name, success, message)
    functionRun = Signal(str, bool, str)    # (name, success, message)

    def __init__(self):
        super().__init__()

        # Ogni variabile: {"name": str, "type": str, "value": str}
        self._variables = []

        # Ogni funzione: {"name": str}
        self._functions = []

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
        # TODO: logica reale di esecuzione (es. comando seriale)
        try:
            print(f"Running function {name}")
            # ... esecuzione reale qui ...
            self.functionRun.emit(name, True, f"{name} executed")
        except Exception as e:
            self.functionRun.emit(name, False, f"Error running {name}: {str(e)}")