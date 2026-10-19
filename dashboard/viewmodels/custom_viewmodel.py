import csv

from PySide6.QtCore import QObject, Signal, Slot
from PySide6.QtWidgets import QFileDialog

class CustomViewModel(QObject):

    scriptGenerated = Signal(str, bool, str, str)  # (script, success, message, file_path) - emitted when script is generated
    connectionStarted = Signal(str)  # (message) - emitted when connection starts

    def __init__(self):
        super().__init__()

    # --- Script Generation and Connection ---

    def _ensure_scripts_directory(self):
        """Crea la cartella scripts/ se non esiste"""
        from pathlib import Path
        scripts_dir = Path(__file__).resolve().parent.parent / "scripts"
        scripts_dir.mkdir(exist_ok=True)
        return scripts_dir

    def _save_script_to_file(self, script: str) -> str:
        """
        Salva lo script in un file .serialx con timestamp.
        
        Args:
            script (str): Il contenuto dello script
        
        Returns:
            str: Il percorso completo del file salvato
        """
        from datetime import datetime
        
        # Crea la cartella scripts se non esiste
        scripts_dir = self._ensure_scripts_directory()
        
        # Crea il nome file con timestamp: config_11-09-2026_153042.serialx
        now = datetime.now()
        filename = f"config_{now:%d-%m-%Y_%H%M%S}.serialx"
        filepath = scripts_dir / filename
        
        # Salva il file
        try:
            with open(filepath, "w", encoding="utf-8") as f:
                f.write(script)
            
            print(f"\n✓ Script saved to: {filepath}")
            return str(filepath)
        
        except Exception as e:
            print(f"✗ Error saving script: {str(e)}")
            return ""

    @Slot(object)
    def generateAndSendConfiguration(self, data):
        """
        Genera lo script dalla configurazione attuale e lo salva in un file.
        
        Args:
            data (object): Dati di configurazione presi da UI
        
        Emits:
            scriptGenerated(script: str, success: bool, message: str, file_path: str)
        """
        try:
            # Importa il generatore di script
            from helpers.script_generator import generate_script
            
            # Estrae i dati di configurazione
            config = self.getConfigurationData(data)
            
            if config is None:
                self.scriptGenerated.emit("", False, "Failed to extract configuration data", "")
                return
            
            # Genera lo script
            script = generate_script(config)
            
            if script is None:
                self.scriptGenerated.emit("", False, "Failed to generate script", "")
                return
            
            # Salva il file
            file_path = self._save_script_to_file(script)
            
            print(f"✓ Script generated successfully!")
            print(f"  File: {file_path}\n")
            
            self.scriptGenerated.emit(script, True, "Script generated and saved successfully", file_path)
            
        except ImportError as e:
            msg = f"Script generator module not found: {str(e)}"
            print(f"✗ {msg}")
            self.scriptGenerated.emit("", False, msg, "")
        except Exception as e:
            msg = f"Error generating script: {str(e)}"
            print(f"✗ {msg}")
            import traceback
            traceback.print_exc()
            self.scriptGenerated.emit("", False, msg, "")

    @Slot(str)
    def startConnection(self, connection_mode):
        """
        Avvia la connessione al dispositivo con la modalità specificata.
        
        Args:
            connection_mode (str): "SerialX" o "Python"
        
        Emits:
            connectionStarted(message: str)
        """
        try:
            msg = f"Attempting {connection_mode} connection..."
            print(f"\n{'='*60}")
            print(f"CONNECTION MODE: {connection_mode}")
            print(f"{'='*60}")
            print(msg)
            
            self.connectionStarted.emit(msg)
            
            # TODO: Implementare la logica di connessione reale
            # Per ora è un placeholder che emette solo il segnale
            
        except Exception as e:
            error_msg = f"Connection error: {str(e)}"
            print(f"✗ {error_msg}")
            self.connectionStarted.emit(error_msg)

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