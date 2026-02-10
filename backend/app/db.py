from typing import Any, Dict, List, Optional
import os

import psycopg2
import psycopg2.extras


def _get_database_url() -> str:
    return os.getenv(
        "DATABASE_URL",
        "postgresql://phoenix:phoenix@db:5432/phoenix_tracks",
    )


def get_connection():
    return psycopg2.connect(_get_database_url())


def get_platforms() -> List[Dict[str, Any]]:
    sql = """
        SELECT
            p.id,
            p.name,
            p.category,
            p.role,
            p.source_url,
            pr.id AS profile_id,
            pr.profile_name,
            pr.speed_mps,
            pr.altitude_m,
            pr.rcs_m2_est,
            pr.rcs_quality,
            pr.heading_deg,
            pr.azimuth_deg,
            pr.source_url AS profile_source_url,
            pr.notes
        FROM platform p
        JOIN platform_profile pr ON pr.platform_id = p.id
        ORDER BY p.id, pr.profile_name;
    """
    platforms: Dict[int, Dict[str, Any]] = {}

    with get_connection() as conn:
        with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
            cur.execute(sql)
            rows = cur.fetchall()

    for row in rows:
        platform_id = int(row["id"])
        if platform_id not in platforms:
            platforms[platform_id] = {
                "id": platform_id,
                "name": row["name"],
                "category": row["category"],
                "role": row["role"],
                "source_url": row["source_url"],
                "profiles": []
            }
        platforms[platform_id]["profiles"].append(
            {
                "id": int(row["profile_id"]),
                "profile_name": row["profile_name"],
                "speed_mps": float(row["speed_mps"]),
                "altitude_m": float(row["altitude_m"]),
                "rcs_m2_est": float(row["rcs_m2_est"]) if row["rcs_m2_est"] is not None else None,
                "rcs_quality": row["rcs_quality"],
                "heading_deg": float(row["heading_deg"]),
                "azimuth_deg": float(row["azimuth_deg"]),
                "source_url": row["profile_source_url"],
                "notes": row["notes"]
            }
        )

    return list(platforms.values())


def get_profile(platform_id: int, profile_name: str) -> Optional[Dict[str, Any]]:
    sql = """
        SELECT
            p.id,
            p.name,
            p.category,
            p.role,
            p.source_url,
            pr.id AS profile_id,
            pr.profile_name,
            pr.speed_mps,
            pr.altitude_m,
            pr.rcs_m2_est,
            pr.rcs_quality,
            pr.source_url AS profile_source_url,
            pr.notes
        FROM platform p
        JOIN platform_profile pr ON pr.platform_id = p.id
        WHERE p.id = %s AND pr.profile_name = %s
        LIMIT 1;
    """

    with get_connection() as conn:
        with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
            cur.execute(sql, (platform_id, profile_name))
            row = cur.fetchone()

    if not row:
        return None

    return {
        "platform_id": int(row["id"]),
        "platform_name": row["name"],
        "category": row["category"],
        "role": row["role"],
        "platform_source_url": row["source_url"],
        "profile_id": int(row["profile_id"]),
        "profile_name": row["profile_name"],
        "speed_mps": float(row["speed_mps"]),
        "altitude_m": float(row["altitude_m"]),
        "rcs_m2_est": float(row["rcs_m2_est"]) if row["rcs_m2_est"] is not None else None,
        "rcs_quality": row["rcs_quality"],
        "profile_source_url": row["profile_source_url"],
        "notes": row["notes"]
    }
