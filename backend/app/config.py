from dataclasses import dataclass
from typing import List, Tuple
import os


def _parse_int(value: str, default: int) -> int:
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def _parse_float(value: str, default: float) -> float:
    try:
        return float(value)
    except (TypeError, ValueError):
        return default


def _parse_float_range(value: str, default: Tuple[float, float]) -> Tuple[float, float]:
    if not value:
        return default
    parts = [p.strip() for p in value.split(",")]
    if len(parts) != 2:
        return default
    return (_parse_float(parts[0], default[0]), _parse_float(parts[1], default[1]))


@dataclass
class Settings:
    prf_hz: int
    sector_step_deg: int
    targets_per_sector: int
    max_range_km: float
    rcs_m2_range: Tuple[float, float]
    allowed_origins: List[str]
    random_seed: int

    @classmethod
    def from_env(cls) -> "Settings":
        prf_hz = _parse_int(os.getenv("PRF_HZ"), 250)
        sector_step_deg = _parse_int(os.getenv("SECTOR_STEP_DEG"), 10)
        targets_per_sector = _parse_int(os.getenv("TARGETS_PER_SECTOR"), 20)
        max_range_km = _parse_float(os.getenv("MAX_RANGE_KM"), 240.0)
        rcs_m2_range = _parse_float_range(os.getenv("RCS_M2_RANGE"), (0.1, 100.0))
        allowed_origins_raw = os.getenv("ALLOWED_ORIGINS", "http://localhost:5173")
        allowed_origins = [o.strip() for o in allowed_origins_raw.split(",") if o.strip()]
        random_seed = _parse_int(os.getenv("SIM_SEED"), 42)
        return cls(
            prf_hz=prf_hz,
            sector_step_deg=sector_step_deg,
            targets_per_sector=targets_per_sector,
            max_range_km=max_range_km,
            rcs_m2_range=rcs_m2_range,
            allowed_origins=allowed_origins,
            random_seed=random_seed,
        )
