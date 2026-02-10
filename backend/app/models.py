from typing import List
from pydantic import BaseModel, Field


class Polar(BaseModel):
    range_m: float = Field(..., ge=0)
    azimuth_deg: float = Field(..., ge=0, lt=360)


class Cartesian(BaseModel):
    x_m: float
    y_m: float


class Target(BaseModel):
    target_id: str
    track_number: int
    sector_deg: float
    range_m: float
    azimuth_deg: float
    x_m: float
    y_m: float
    rcs_m2: float
    radial_velocity_mps: float


class AsterixRecord(BaseModel):
    target_id: str
    track_number: int
    time_of_day_s: float
    polar: Polar
    cartesian: Cartesian
    rcs_m2: float
    raw_hex: str
    raw_base64: str


class PlatformProfile(BaseModel):
    id: int
    profile_name: str
    speed_mps: float
    altitude_m: float
    rcs_m2_est: float | None
    rcs_quality: str
    source_url: str
    notes: str


class Platform(BaseModel):
    id: int
    name: str
    category: str
    role: str
    source_url: str
    profiles: List[PlatformProfile]


class CustomTarget(BaseModel):
    track_id: int
    platform_id: int
    platform_name: str
    profile_name: str
    range_m: float
    azimuth_deg: float
    x_m: float
    y_m: float
    altitude_m: float
    heading_deg: float
    speed_mps: float
    rcs_m2: float | None
    time_of_day_s: float
    raw_hex: str


class MasterTable(BaseModel):
    prf_hz: int
    frame_index: int
    motion_enabled: bool
    targets: List[Target]
    asterix48: List[AsterixRecord]
    custom_targets: List[CustomTarget]
