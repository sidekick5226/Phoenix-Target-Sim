# Phoenix Track Sim

Simulated radar targets and associated tracks with a React + Tailwind GUI and a Python FastAPI backend.

## Features
- Simulates 20 targets per 10-degree sector across 360 degrees with PRF at 250 Hz.
- Varies target RCS values across a configurable range.
- Produces an ASTERIX-48 master table (subset fields) and binary encode/decode endpoints.
- Frontend radar scope, master table view, and motion toggle.
- Custom track creation from Postgres platform profiles (range, azimuth, heading, profile).
- Custom tracks render as a separate layer and include real ASTERIX-48 hex rows.

## Backend

### Run
1) Create and activate a Python virtual environment.
2) Install dependencies from backend/requirements.txt.
3) Start the API server with `uvicorn app.main:app --reload` from the backend directory.

### Configuration
Set these environment variables before starting the backend (optional):
- PRF_HZ (default 250)
- SECTOR_STEP_DEG (default 10)
- TARGETS_PER_SECTOR (default 20)
- MAX_RANGE_KM (default 240)
- RCS_M2_RANGE (default "0.1,100")
- ALLOWED_ORIGINS (comma-separated, default "http://localhost:5173")
- DATABASE_URL (default "postgresql://phoenix:phoenix@db:5432/phoenix_tracks")
- SIM_SEED (default 42)

### ASTERIX-48 subset fields
The binary encoder/decoder uses a consistent subset of CAT 048 items:
- I048/010 Data Source Identifier (SAC/SIC)
- I048/140 Time of Day (1/128 s)
- I048/040 Measured Position in Polar (range, azimuth)
- I048/042 Calculated Position in Cartesian (x, y)
- I048/161 Track Number
- I048/130 Radar Plot Characteristics (RCS subfield)

Scaling used:
- Range: 2 meters per LSB
- Azimuth: 0..360 mapped to 0..65535
- X/Y: 4 meters per LSB (signed)
- RCS: encoded in dBsm for CAT 048, derived from linear RCS in m²

### API
- GET /api/config
- GET /api/state
- GET /api/platforms
- POST /api/asterix/encode
- POST /api/asterix/decode
- POST /api/motion
- POST /api/custom-tracks

## Frontend

### Run
1) Install dependencies with `npm install` from the frontend directory.
2) Start the dev server with `npm run dev`.

### Configuration
- VITE_API_BASE_URL (default "http://localhost:8000")

## Docker

### Build and Run
- `docker compose build`
- `docker compose up -d`

Frontend is exposed on http://localhost:3000 and the backend on http://localhost:8000.

## Postgres

Default connection (Docker):
- Host: localhost
- Port: 5432
- Database: phoenix_tracks
- User: phoenix
- Password: phoenix

Schema is initialized from db/init.sql.
Seeded data includes a starter set of aircraft and naval platform profiles with speed and altitude fields and RCS values marked as estimates where public data is limited.

## Custom Tracks

Use the Custom Tracks panel in the UI to select a platform + profile and set range/azimuth/heading.
Custom track time starts at creation and increments from that moment. Each custom track also generates a valid CAT 048 hex row in the master table.

## Makefile

Common targets:
- `make install`
- `make run-backend`
- `make run-frontend`
- `make docker-build`
- `make docker-up`
- `make docker-down`

## Notes
- The frontend refreshes at 5 Hz for readability while the simulator updates at PRF internally.
- The ASTERIX-48 encoder/decoder is a focused subset to keep the simulator portable.
