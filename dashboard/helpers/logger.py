import logging
import sys
from datetime import datetime, timezone
from zoneinfo import ZoneInfo
from pathlib import Path

class _Formatter(logging.Formatter):
    COLORS = {
        logging.DEBUG:   "\033[36m",  # cyan
        logging.INFO:    "\033[37m",  # bianco
        logging.WARNING: "\033[33m",  # giallo
        logging.ERROR:   "\033[31m",  # rosso
    }
    RESET = "\033[0m"

    def __init__(self, tz=timezone.utc, color=False):
        super().__init__()
        self.tz = tz
        self.color = color

    def format(self, record):
        ts = datetime.fromtimestamp(record.created, self.tz).strftime("%Y-%m-%d %H:%M:%S")
        msg = f"[{ts}] [{record.levelname}] {record.getMessage()}"
        if record.exc_info:
            msg += "\n" + self.formatException(record.exc_info)
        if self.color:
            msg = f"{self.COLORS.get(record.levelno, '')}{msg}{self.RESET}"
        return msg


def create_logger(name="app", level=logging.DEBUG, tz="UTC", file_path=None, console=True):
    log = logging.getLogger(name)
    log.setLevel(level)
    log.handlers.clear()
    zone = timezone.utc if tz == "UTC" else ZoneInfo(tz)

    if console:
        h = logging.StreamHandler(sys.stdout)
        h.setFormatter(_Formatter(zone, color=sys.stdout.isatty()))
        log.addHandler(h)

    if file_path:
        Path(file_path).parent.mkdir(parents=True, exist_ok=True)
        fh = logging.FileHandler(file_path, encoding="utf-8")
        fh.setFormatter(_Formatter(zone))
        log.addHandler(fh)

    return log
