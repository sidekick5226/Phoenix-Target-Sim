from dataclasses import dataclass
from typing import List
import base64
import math
import random
import time

from .asterix48 import Asterix48Data, encode_record, rcs_m2_to_dbsm
from .config import Settings
from .models import AsterixRecord, CustomTarget, MasterTable, Target


@dataclass
class TrackState:
    target_id: str
    track_number: int
    sector_deg: float
    azimuth_deg: float
    range_m: float
    radial_velocity_mps: float
    rcs_m2: float


@dataclass
class CustomTrack:
    track_id: int
    platform_id: int
    platform_name: str
    profile_name: str
    x_m: float
    y_m: float
    range_m: float
    azimuth_deg: float
    altitude_m: float
    heading_deg: float
    speed_mps: float
    rcs_m2: float | None
    created_time_s: float


class Simulator:
    def __init__(self, settings: Settings) -> None:
        self.settings = settings
        self._rand = random.Random(settings.random_seed)
        self._tracks: List[TrackState] = []
        self._custom_tracks: List[CustomTrack] = []
        self._frame_index = 0
        self._time_of_day_s = 0.0
        self._last_update = time.monotonic()
        self._motion_enabled = False
        self._build_tracks()

    def set_motion(self, enabled: bool) -> None:
        self._motion_enabled = enabled

    def motion_enabled(self) -> bool:
        return self._motion_enabled

    def set_custom_tracks(self, tracks: List[CustomTrack]) -> None:
        existing = {track.track_id: track for track in self._custom_tracks}
        for track in tracks:
            prior = existing.get(track.track_id)
            if prior is None:
                track.created_time_s = self._time_of_day_s
            else:
                track.created_time_s = prior.created_time_s
        self._custom_tracks = tracks

    def _build_tracks(self) -> None:
        self._tracks.clear()
        track_number = 1
        max_range_m = self.settings.max_range_km * 1000.0
        step = self.settings.sector_step_deg
        per_sector = self.settings.targets_per_sector

        for sector in range(0, 360, step):
            for idx in range(per_sector):
                azimuth = sector + (step / 2.0)
                range_m = max_range_m * (0.1 + 0.9 * (idx + 1) / per_sector)
                velocity = self._rand.uniform(-35.0, 35.0)
                rcs_min, rcs_max = self.settings.rcs_m2_range
                rcs = self._rand.uniform(rcs_min, rcs_max)
                target_id = f"T{track_number:04d}"
                self._tracks.append(
                    TrackState(
                        target_id=target_id,
                        track_number=track_number,
                        sector_deg=sector,
                        azimuth_deg=azimuth % 360.0,
                        range_m=max(200.0, min(max_range_m, range_m)),
                        radial_velocity_mps=velocity,
                        rcs_m2=rcs,
                    )
                )
                track_number += 1

    def _step_tracks(self, steps: int) -> None:
        if steps <= 0:
            return
        max_range_m = self.settings.max_range_km * 1000.0
        dt = steps / self.settings.prf_hz
        for track in self._tracks:
            track.range_m += track.radial_velocity_mps * dt
            if track.range_m < 200.0:
                track.range_m = 200.0
                track.radial_velocity_mps *= -1
            if track.range_m > max_range_m:
                track.range_m = max_range_m
                track.radial_velocity_mps *= -1
        self._time_of_day_s += dt
        self._frame_index += 1

    def _step_custom_tracks(self, dt: float) -> None:
        if not self._custom_tracks:
            return
        max_range_m = self.settings.max_range_km * 1000.0
        for track in self._custom_tracks:
            heading_rad = math.radians(track.heading_deg)
            track.x_m += math.cos(heading_rad) * track.speed_mps * dt
            track.y_m += math.sin(heading_rad) * track.speed_mps * dt
            track.range_m = math.hypot(track.x_m, track.y_m)
            if track.range_m > max_range_m:
                track.range_m = max_range_m
                track.heading_deg = (track.heading_deg + 180.0) % 360.0
                heading_rad = math.radians(track.heading_deg)
                track.x_m = math.cos(heading_rad) * track.range_m
                track.y_m = math.sin(heading_rad) * track.range_m
            track.azimuth_deg = (math.degrees(math.atan2(track.y_m, track.x_m)) + 360.0) % 360.0

    def update(self) -> None:
        now = time.monotonic()
        delta = max(0.0, now - self._last_update)
        steps = max(1, int(delta * self.settings.prf_hz))
        dt = steps / self.settings.prf_hz
        if self._motion_enabled:
            self._step_tracks(steps)
            self._step_custom_tracks(dt)
        self._last_update = now

    def snapshot(self) -> MasterTable:
        self.update()
        targets: List[Target] = []
        asterix: List[AsterixRecord] = []
        custom_targets: List[CustomTarget] = []

        for track in self._tracks:
            azimuth_rad = math.radians(track.azimuth_deg)
            x_m = math.cos(azimuth_rad) * track.range_m
            y_m = math.sin(azimuth_rad) * track.range_m
            targets.append(
                Target(
                    target_id=track.target_id,
                    track_number=track.track_number,
                    sector_deg=track.sector_deg,
                    range_m=track.range_m,
                    azimuth_deg=track.azimuth_deg,
                    x_m=x_m,
                    y_m=y_m,
                    rcs_m2=track.rcs_m2,
                    radial_velocity_mps=track.radial_velocity_mps,
                )
            )

            rcs_dbsm = rcs_m2_to_dbsm(track.rcs_m2)
            record = Asterix48Data(
                sac=1,
                sic=1,
                time_of_day_s=self._time_of_day_s,
                range_m=track.range_m,
                azimuth_deg=track.azimuth_deg,
                x_m=x_m,
                y_m=y_m,
                track_number=track.track_number,
                rcs_dbsm=rcs_dbsm,
            )
            raw = encode_record(record)
            asterix.append(
                AsterixRecord(
                    target_id=track.target_id,
                    track_number=track.track_number,
                    time_of_day_s=self._time_of_day_s,
                    polar={"range_m": track.range_m, "azimuth_deg": track.azimuth_deg},
                    cartesian={"x_m": x_m, "y_m": y_m},
                    rcs_m2=track.rcs_m2,
                    raw_hex=raw.hex(),
                    raw_base64=base64.b64encode(raw).decode("ascii"),
                )
            )

        for track in self._custom_tracks:
            custom_time_s = max(0.0, self._time_of_day_s - track.created_time_s)
            rcs_dbsm = rcs_m2_to_dbsm(track.rcs_m2) if track.rcs_m2 is not None else -64.0
            record = Asterix48Data(
                sac=1,
                sic=1,
                time_of_day_s=custom_time_s,
                range_m=track.range_m,
                azimuth_deg=track.azimuth_deg,
                x_m=track.x_m,
                y_m=track.y_m,
                track_number=8000 + track.track_id,
                rcs_dbsm=rcs_dbsm,
            )
            raw = encode_record(record)
            custom_targets.append(
                CustomTarget(
                    track_id=track.track_id,
                    platform_id=track.platform_id,
                    platform_name=track.platform_name,
                    profile_name=track.profile_name,
                    range_m=track.range_m,
                    azimuth_deg=track.azimuth_deg,
                    x_m=track.x_m,
                    y_m=track.y_m,
                    altitude_m=track.altitude_m,
                    heading_deg=track.heading_deg,
                    speed_mps=track.speed_mps,
                    rcs_m2=track.rcs_m2,
                    time_of_day_s=custom_time_s,
                    raw_hex=raw.hex(),
                )
            )

        return MasterTable(
            prf_hz=self.settings.prf_hz,
            frame_index=self._frame_index,
            motion_enabled=self._motion_enabled,
            targets=targets,
            asterix48=asterix,
            custom_targets=custom_targets,
        )
