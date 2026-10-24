import json
import re
import urllib.error
import urllib.request
from dataclasses import dataclass
from app import __appName__, __appVersion__, __githubRepo__, __gitHubApiUrl__

@dataclass
class UpdateResult:
    update_available: bool = False
    latest_version: str = ""
    release_url: str = ""
    notes: str = ""
    error: str = ""


def _parse_version(version: str) -> tuple:
    """'v1.2.3-beta' -> (1, 2, 3). Ignora prefisso 'v' e suffissi."""
    version = version.strip().lstrip("vV")
    parts = re.findall(r"\d+", version.split("-")[0].split("+")[0])
    return tuple(int(p) for p in parts) or (0,)


def is_newer(latest: str, current: str) -> bool:
    a, b = _parse_version(latest), _parse_version(current)
    # normalizza la lunghezza: (1, 2) == (1, 2, 0)
    n = max(len(a), len(b))
    a += (0,) * (n - len(a))
    b += (0,) * (n - len(b))
    return a > b


def check_for_updates(current_version: str = __appVersion__, timeout: int = 8) -> UpdateResult:
    """Interroga le GitHub Releases (ultima release stabile, no draft/prerelease)."""
    req = urllib.request.Request(
        __gitHubApiUrl__,
        headers={
            "Accept": "application/vnd.github+json",
            "User-Agent": f"{__appName__}-updater",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            data = json.load(resp)
    except urllib.error.HTTPError as e:
        if e.code == 404:  # nessuna release pubblicata
            return UpdateResult()
        if e.code in (403, 429):
            return UpdateResult(error="GitHub rate limit reached. Try again later.")
        return UpdateResult(error=f"GitHub error ({e.code}).")
    except (urllib.error.URLError, TimeoutError):
        return UpdateResult(error="Unable to reach GitHub. Check your connection.")
    except json.JSONDecodeError:
        return UpdateResult(error="Invalid response from GitHub.")

    tag = data.get("tag_name", "")
    return UpdateResult(
        update_available=is_newer(tag, current_version),
        latest_version=tag.lstrip("vV"),
        release_url=data.get("html_url", ""),
        notes=data.get("body", "") or "",
    )
