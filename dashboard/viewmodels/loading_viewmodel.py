import random
from datetime import datetime

from PySide6.QtCore import QObject, Property, Signal, Slot, QTimer


class LoadingViewModel(QObject):

    progressChanged = Signal()
    logsChanged = Signal()
    loadChanged = Signal()

    def __init__(self):
        super().__init__()

        self._progress = 65.0
        self._logs = [
            {"time": "14:22:01", "level": "INFO", "msg": "Starting connection to remote cluster node..."},
            {"time": "14:22:01", "level": "DEBUG", "msg": "Handshake initiated via protocol secure-v4."},
            {"time": "14:22:03", "level": "INFO", "msg": "Fetching remote manifest from /dist/v2.4.0/master.json"},
            {"time": "14:22:04", "level": "DEBUG", "msg": "Manifest received: 4,092 entries validated."},
            {"time": "14:22:05", "level": "WARN", "msg": "Node latency detected: 142ms. Adjusting buffer size."},
            {"time": "14:22:08", "level": "INFO", "msg": "Decompressing packet streams (7/12 completed)..."},
            {"time": "14:22:10", "level": "DEBUG", "msg": "Checksum validation for shard #08 passed."},
            {"time": "14:22:12", "level": "DEBUG", "msg": "Checksum validation for shard #09 passed."},
            {"time": "14:22:15", "level": "INFO", "msg": "Re-indexing local cache to match remote state..."},
            {"time": "14:22:18", "level": "ERROR", "msg": "Connection dropped on secondary socket. Retrying..."},
            {"time": "14:22:20", "level": "INFO", "msg": "Connection re-established. Resuming from offset 0x4F2A."},
            {"time": "14:22:22", "level": "DEBUG", "msg": "Syncing metadata for 1,200 objects."},
            {"time": "14:22:25", "level": "INFO", "msg": "Processing data stream (Chunk 102/256)..."},
        ]
        self._cpu = 42
        self._mem = 1.2

        # Simulation timer
        self.timer = QTimer(self)
        self.timer.timeout.connect(self.update_system)
        self.timer.start(1000)

    @Property(float, notify=progressChanged)
    def progress(self):
        return self._progress

    @Property(list, notify=logsChanged)
    def logs(self):
        return self._logs

    @Property(str, notify=loadChanged)
    def systemLoad(self):
        return f"CPU: {self._cpu}% | MEM: {self._mem}GB"

    def update_system(self):
        self._progress = min(100.0, self._progress + 0.1)
        if self._progress >= 100.0:
            self._progress = 0.0
        self.progressChanged.emit()

        if random.random() > 0.8:
            new_log = {
                "time": datetime.now().strftime("%H:%M:%S"),
                "level": random.choice(["INFO", "DEBUG", "WARN", "ERROR"]),
                "msg": f"Processing data stream (Chunk {random.randint(100, 256)}/256)...",
            }
            self._logs.append(new_log)
            if len(self._logs) > 50:
                self._logs.pop(0)
            self.logsChanged.emit()

        self._cpu = random.randint(35, 55)
        self.loadChanged.emit()