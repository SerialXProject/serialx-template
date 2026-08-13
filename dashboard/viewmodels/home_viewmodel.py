from PySide6.QtCore import QObject, Property, Signal, Slot, QTimer, QDateTime


class HomeViewModel(QObject):

    timeChanged = Signal()
    dateChanged = Signal()

    def __init__(self):
        super().__init__()

        self._time = ""
        self._date = ""

        self.timer = QTimer(self)
        self.timer.timeout.connect(self._update)
        self.timer.start(1000)

        self._update()

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

    @Slot()
    def openHelp(self):
        from pathlib import Path
        import webbrowser

        file_path = Path(__file__).resolve().parents[1] / "docs" / "index.html"
        webbrowser.open(f"file://{file_path}")