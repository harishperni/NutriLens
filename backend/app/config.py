import os
from pathlib import Path
from typing import Dict


def _load_dotenv_map() -> Dict[str, str]:
    env_map: Dict[str, str] = {}
    base_dir = Path(__file__).resolve().parents[1]  # backend/
    candidates = [
        base_dir / ".env",
        base_dir.parent / ".env",
    ]
    for path in candidates:
        if not path.exists():
            continue
        for raw_line in path.read_text(encoding="utf-8").splitlines():
            line = raw_line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            env_map[key.strip()] = value.strip().strip("'").strip('"')
    return env_map


def _get_secret(key: str) -> str:
    env_value = os.getenv(key, "").strip()
    if env_value:
        return env_value
    return _load_dotenv_map().get(key, "").strip()


def get_usda_api_key() -> str:
    return _get_secret("USDA_API_KEY")


def get_spoonacular_api_key() -> str:
    return _get_secret("SPOONACULAR_API_KEY")


def get_jwt_secret() -> str:
    return _get_secret("JWT_SECRET") or "dev-only-change-me"


def external_food_apis_enabled() -> bool:
    return os.getenv("ENABLE_EXTERNAL_FOOD_APIS", "true").lower() in {
        "1",
        "true",
        "yes",
    }


def debug_api_enabled() -> bool:
    return os.getenv("ENABLE_DEBUG_API", "false").lower() in {
        "1",
        "true",
        "yes",
    }
