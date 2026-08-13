from datetime import datetime
from typing import Tuple
from pySerialX.models.serialx_data import SerialXData
from pySerialX.version import __version__, __app_name__, __author__, __language__

def generate_script(data: SerialXData) -> str:
    try:
        if data is None:
            return None

        now = datetime.now()
        lines = []

        # App info
        lines.append(f"#!{__language__.lower()}")
        lines.append("")
        lines.append(f"@{__app_name__}")
        lines.append(f"@v{__version__}")
        lines.append("")
        lines.append(f"Script generato il {now.strftime('%d/%m/%Y')} alle {now.strftime('%H:%M:%S')}")
        lines.append("")
        lines.append("")  # Aggiungere !min_version
        lines.append("")
        lines.append("// DateTime")

        # Time and date
        time_str = data.time.strftime("%H:%M") if data.time else "[NOW]"
        date_str = data.date.strftime("%d/%m/%Y") if data.date else "[NOW]"
        lines.append(f"set time {time_str}")
        lines.append(f"set date {date_str}")
        lines.append(f"set timeformat {'24h' if data.is_24_hour_format else '12h'}")
        lines.append(f"set day {data.day_of_week if data.day_of_week is not None else '[UNKNOWN]'}")
        lines.append("")

        # Daily alarms
        lines.append("// Daily Alarms")
        for alarm in data.daily_alarms:
            if alarm is not None:
                lines.append(f"set dailyalarm {alarm.name} {alarm.time.strftime('%H:%M')}")

        # Week alarms
        lines.append("// Week Alarms")
        for alarm in data.week_alarms:
            if alarm is not None:
                lines.append(f"set weekalarm{alarm.days} {alarm.name} {alarm.time.strftime('%H:%M')}")

        # Sensors
        lines.append("")
        lines.append("// Sensors")
        lines.append(f"set lightValue {data.night_value}")
        lines.append(f"set temperatureError {data.temperature_error}")

        script = "\n".join(lines)

        # Debug output
        print("------------ SCRIPT GENERATO ------------")
        print(script)

        return script

    except Exception as e:
        print(f"Error generating script: {e}")
        return None
    
def importScript(script: str) -> SerialXData:
    pass
    # Implementare la logica per importare uno script e creare un oggetto SerialAData corrispondente