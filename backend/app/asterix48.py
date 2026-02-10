from dataclasses import dataclass
from typing import Dict, Tuple
import math


CAT = 48

RANGE_SCALE_M = 2.0
XY_SCALE_M = 4.0


@dataclass
class Asterix48Data:
    sac: int
    sic: int
    time_of_day_s: float
    range_m: float
    azimuth_deg: float
    x_m: float
    y_m: float
    track_number: int
    rcs_dbsm: float


def _clamp(value: int, min_value: int, max_value: int) -> int:
    return max(min_value, min(max_value, value))


def _encode_time_of_day(time_s: float) -> bytes:
    value = int(round(time_s * 128.0)) & 0xFFFFFF
    return value.to_bytes(3, "big")


def _decode_time_of_day(data: bytes) -> float:
    return int.from_bytes(data, "big") / 128.0


def _encode_polar(range_m: float, azimuth_deg: float) -> bytes:
    rho = int(round(range_m / RANGE_SCALE_M))
    rho = _clamp(rho, 0, 0xFFFF)
    theta = int(round((azimuth_deg % 360.0) / 360.0 * 65535))
    theta = _clamp(theta, 0, 0xFFFF)
    return rho.to_bytes(2, "big") + theta.to_bytes(2, "big")


def _decode_polar(data: bytes) -> Tuple[float, float]:
    rho = int.from_bytes(data[:2], "big") * RANGE_SCALE_M
    theta = int.from_bytes(data[2:4], "big") / 65535.0 * 360.0
    return rho, theta


def _encode_cartesian(x_m: float, y_m: float) -> bytes:
    x = int(round(x_m / XY_SCALE_M))
    y = int(round(y_m / XY_SCALE_M))
    x = _clamp(x, -32768, 32767)
    y = _clamp(y, -32768, 32767)
    return x.to_bytes(2, "big", signed=True) + y.to_bytes(2, "big", signed=True)


def _decode_cartesian(data: bytes) -> Tuple[float, float]:
    x = int.from_bytes(data[:2], "big", signed=True) * XY_SCALE_M
    y = int.from_bytes(data[2:4], "big", signed=True) * XY_SCALE_M
    return x, y


def _encode_track_number(track_number: int) -> bytes:
    value = _clamp(track_number, 0, 0xFFFF)
    return value.to_bytes(2, "big")


def _decode_track_number(data: bytes) -> int:
    return int.from_bytes(data, "big")


def _encode_rcs(rcs_dbsm: float) -> bytes:
    rcs_int = int(round(rcs_dbsm))
    rcs_int = _clamp(rcs_int, -64, 63)
    rcs_byte = rcs_int + 64
    return bytes([0x40, rcs_byte])


def _decode_rcs(data: bytes) -> float:
    if not data:
        return 0.0
    rcs_byte = data[1]
    return float(rcs_byte - 64)


def rcs_m2_to_dbsm(rcs_m2: float) -> float:
    if rcs_m2 <= 0:
        return -64.0
    return 10.0 * math.log10(rcs_m2)


def rcs_dbsm_to_m2(rcs_dbsm: float) -> float:
    return 10 ** (rcs_dbsm / 10.0)


def encode_record(record: Asterix48Data) -> bytes:
    fspec = 0
    payload = bytearray()

    fspec |= 1 << 6
    payload.extend(bytes([record.sac & 0xFF, record.sic & 0xFF]))

    fspec |= 1 << 5
    payload.extend(_encode_time_of_day(record.time_of_day_s))

    fspec |= 1 << 4
    payload.extend(_encode_polar(record.range_m, record.azimuth_deg))

    fspec |= 1 << 3
    payload.extend(_encode_cartesian(record.x_m, record.y_m))

    fspec |= 1 << 2
    payload.extend(_encode_track_number(record.track_number))

    fspec |= 1 << 1
    payload.extend(_encode_rcs(record.rcs_dbsm))

    fspec_byte = fspec & 0x7F
    length = 1 + 2 + 1 + len(payload)
    header = bytes([CAT]) + length.to_bytes(2, "big") + bytes([fspec_byte])
    return header + bytes(payload)


def decode_record(message: bytes) -> Dict[str, float]:
    if len(message) < 4:
        raise ValueError("Message too short")
    if message[0] != CAT:
        raise ValueError("Invalid CAT")
    total_len = int.from_bytes(message[1:3], "big")
    if total_len != len(message):
        raise ValueError("Length mismatch")

    fspec = message[3]
    offset = 4
    data: Dict[str, float] = {}

    if fspec & (1 << 6):
        data["sac"] = message[offset]
        data["sic"] = message[offset + 1]
        offset += 2
    if fspec & (1 << 5):
        data["time_of_day_s"] = _decode_time_of_day(message[offset : offset + 3])
        offset += 3
    if fspec & (1 << 4):
        rho, theta = _decode_polar(message[offset : offset + 4])
        data["range_m"] = rho
        data["azimuth_deg"] = theta
        offset += 4
    if fspec & (1 << 3):
        x, y = _decode_cartesian(message[offset : offset + 4])
        data["x_m"] = x
        data["y_m"] = y
        offset += 4
    if fspec & (1 << 2):
        data["track_number"] = _decode_track_number(message[offset : offset + 2])
        offset += 2
    if fspec & (1 << 1):
        data["rcs_dbsm"] = _decode_rcs(message[offset : offset + 2])
        offset += 2

    return data
