import sys
from pathlib import Path

from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine

from viewmodels.home_viewmodel import HomeViewModel
from viewmodels.settings_viewmodel import SettingsViewModel
from viewmodels.loading_viewmodel import LoadingViewModel
from viewmodels.var_edit_viewmodel import VarEditViewModel

def main():
    app = QApplication(sys.argv)

    engine = QQmlApplicationEngine()

    settings_vm = SettingsViewModel()
    loading_vm = LoadingViewModel()
    var_edit_vm = VarEditViewModel()
    home_vm = HomeViewModel(var_edit_viewmodel=var_edit_vm)
    
    # Passiamo homeViewModel a varEditViewModel per l'esecuzione delle funzioni
    var_edit_vm._home_viewmodel = home_vm

    engine.rootContext().setContextProperty("homeViewModel", home_vm)
    engine.rootContext().setContextProperty("settingsViewModel", settings_vm)
    engine.rootContext().setContextProperty("loadingViewModel", loading_vm)
    engine.rootContext().setContextProperty("varEditViewModel", var_edit_vm)

    qml_file = Path(__file__).resolve().parent / "qml" / "main.qml"

    engine.load(str(qml_file))

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()