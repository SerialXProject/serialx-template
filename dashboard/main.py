import sys
from pathlib import Path

from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine

from viewmodels.home_viewmodel import HomeViewModel
from viewmodels.settings_viewmodel import SettingsViewModel
from viewmodels.loading_viewmodel import LoadingViewModel

def main():
    app = QApplication(sys.argv)

    engine = QQmlApplicationEngine()

    home_vm = HomeViewModel()
    settings_vm = SettingsViewModel()
    loading_vm = LoadingViewModel()

    engine.rootContext().setContextProperty("homeViewModel", home_vm)
    engine.rootContext().setContextProperty("settingsViewModel", settings_vm)
    engine.rootContext().setContextProperty("loadingViewModel", loading_vm)

    qml_file = Path(__file__).resolve().parent / "qml" / "main.qml"

    engine.load(str(qml_file))

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()