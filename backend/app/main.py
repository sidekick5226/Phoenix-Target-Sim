from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import math

from .asterix48 import decode_record, encode_record, Asterix48Data, rcs_dbsm_to_m2, rcs_m2_to_dbsm
from .config import Settings
from .db import get_platforms, get_profile
from .simulator import Simulator, CustomTrack


settings = Settings.from_env()
app = FastAPI(title="Phoenix Track Sim")

allow_all = any(origin == "*" for origin in settings.allowed_origins)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins if not allow_all else ["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

simulator = Simulator(settings)


class EncodeRequest(BaseModel):
    sac: int
    sic: int
    time_of_day_s: float
    range_m: float
    azimuth_deg: float
    x_m: float
    y_m: float
    track_number: int
    rcs_m2: float


class DecodeRequest(BaseModel):
    hex: str


class MotionRequest(BaseModel):
    enabled: bool


class CustomTrackRequest(BaseModel):
    track_id: int | None = None
    platform_id: int
    profile_name: str
    range_m: float
    azimuth_deg: float
    heading_deg: float


@app.get("/api/config")
async def get_config():
    return {
        "prf_hz": settings.prf_hz,
        "sector_step_deg": settings.sector_step_deg,
        "targets_per_sector": settings.targets_per_sector,
        "max_range_km": settings.max_range_km,
        "rcs_m2_range": settings.rcs_m2_range,
        "motion_enabled": simulator.motion_enabled(),
    }


@app.get("/api/state")
async def get_state():
    table = simulator.snapshot()
    return table.model_dump()


@app.post("/api/motion")
async def set_motion(payload: MotionRequest):
    simulator.set_motion(payload.enabled)
    return {"motion_enabled": simulator.motion_enabled()}


@app.get("/api/platforms")
async def list_platforms():
    return {"platforms": get_platforms()}


@app.post("/api/custom-tracks")
async def set_custom_tracks(payload: list[CustomTrackRequest]):
    tracks = []
    for index, entry in enumerate(payload, start=1):
        track_id = entry.track_id if entry.track_id is not None else index
        profile = get_profile(entry.platform_id, entry.profile_name)
        if profile is None:
            raise HTTPException(status_code=400, detail="Invalid platform or profile")
        azimuth_rad = math.radians(entry.azimuth_deg)
        range_m = max(0.0, entry.range_m)
        x_m = math.cos(azimuth_rad) * range_m
        y_m = math.sin(azimuth_rad) * range_m
        tracks.append(
            CustomTrack(
                track_id=track_id,
                platform_id=profile["platform_id"],
                platform_name=profile["platform_name"],
                profile_name=profile["profile_name"],
                x_m=x_m,
                y_m=y_m,
                range_m=range_m,
                azimuth_deg=entry.azimuth_deg % 360.0,
                altitude_m=profile["altitude_m"],
                heading_deg=entry.heading_deg % 360.0,
                speed_mps=profile["speed_mps"],
                rcs_m2=profile["rcs_m2_est"],
                created_time_s=0.0,
            )
        )
    simulator.set_custom_tracks(tracks)
    return {"count": len(tracks)}


@app.post("/api/asterix/encode")
async def encode_asterix(payload: EncodeRequest):
    data = payload.model_dump()
    data["rcs_dbsm"] = rcs_m2_to_dbsm(data.pop("rcs_m2"))
    record = Asterix48Data(**data)
    data = encode_record(record)
    return {"hex": data.hex(), "length": len(data)}


@app.post("/api/asterix/decode")
async def decode_asterix(payload: DecodeRequest):
    data = bytes.fromhex(payload.hex)
    decoded = decode_record(data)
    if "rcs_dbsm" in decoded:
        decoded["rcs_m2"] = rcs_dbsm_to_m2(decoded["rcs_dbsm"])
    return decoded
