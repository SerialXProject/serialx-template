import sys
from pathlib import Path

from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine

from viewmodels.home_viewmodel import HomeViewModel


def main():
    app = QApplication(sys.argv)

    engine = QQmlApplicationEngine()

    home_vm = HomeViewModel()

    engine.rootContext().setContextProperty(
        "homeViewModel",
        home_vm
    )

    qml_file = Path(__file__).resolve().parent / "qml" / "main.qml"

    engine.load(str(qml_file))

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()