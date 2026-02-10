import { useEffect, useMemo, useRef, useState } from "react";

const apiBase = import.meta.env.VITE_API_BASE_URL || "http://localhost:8000";

const formatNumber = (value, digits = 1) => {
  if (value === undefined || value === null || Number.isNaN(value)) return "-";
  return Number(value).toFixed(digits);
};

const formatAzimuth = (value) => `${formatNumber(value, 1)} deg`;
const formatRange = (value) => `${formatNumber(value / 1000, 2)} km`;

export default function App() {
  const [config, setConfig] = useState(null);
  const [state, setState] = useState(null);
  const [lastUpdated, setLastUpdated] = useState(null);
  const [motionEnabled, setMotionEnabled] = useState(false);
  const [platforms, setPlatforms] = useState([]);
  const [selectedPlatformId, setSelectedPlatformId] = useState("");
  const [selectedProfile, setSelectedProfile] = useState("");
  const [rangeInput, setRangeInput] = useState("50000");
  const [azimuthInput, setAzimuthInput] = useState("0");
  const [headingInput, setHeadingInput] = useState("0");
  const [customTracks, setCustomTracks] = useState([]);
  const nextTrackIdRef = useRef(1);

  useEffect(() => {
    fetch(`${apiBase}/api/config`)
      .then((res) => res.json())
      .then((data) => {
        setConfig(data);
        setMotionEnabled(Boolean(data.motion_enabled));
      })
      .catch(() => null);
  }, [apiBase]);

  useEffect(() => {
    fetch(`${apiBase}/api/platforms`)
      .then((res) => res.json())
      .then((data) => {
        setPlatforms(data.platforms || []);
        if (data.platforms?.length) {
          const first = data.platforms[0];
          setSelectedPlatformId(String(first.id));
          setSelectedProfile(first.profiles?.[0]?.profile_name || "");
        }
      })
      .catch(() => null);
  }, [apiBase]);

  useEffect(() => {
    let mounted = true;
    const loadState = () => {
      fetch(`${apiBase}/api/state`)
        .then((res) => res.json())
        .then((data) => {
          if (!mounted) return;
          setState(data);
          setMotionEnabled(Boolean(data.motion_enabled));
          setLastUpdated(new Date());
        })
        .catch(() => null);
    };

    loadState();
    const interval = setInterval(loadState, 200);
    return () => {
      mounted = false;
      clearInterval(interval);
    };
  }, [apiBase]);

  const handleMotionToggle = (event) => {
    const nextValue = event.target.checked;
    setMotionEnabled(nextValue);
    fetch(`${apiBase}/api/motion`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ enabled: nextValue })
    }).catch(() => null);
  };

  const selectedPlatform = platforms.find(
    (platform) => String(platform.id) === String(selectedPlatformId)
  );
  const availableProfiles = selectedPlatform?.profiles ?? [];

  const syncCustomTracks = (tracks) => {
    fetch(`${apiBase}/api/custom-tracks`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(tracks)
    }).catch(() => null);
  };

  const handleAddTrack = () => {
    if (!selectedPlatformId || !selectedProfile) return;
    const trackId = nextTrackIdRef.current;
    nextTrackIdRef.current += 1;
    const next = [
      ...customTracks,
      {
        track_id: trackId,
        platform_id: Number(selectedPlatformId),
        profile_name: selectedProfile,
        range_m: Number(rangeInput),
        azimuth_deg: Number(azimuthInput),
        heading_deg: Number(headingInput)
      }
    ];
    setCustomTracks(next);
    syncCustomTracks(next);
  };

  const handleRemoveTrack = (index) => {
    const next = customTracks.filter((_, idx) => idx !== index);
    setCustomTracks(next);
    syncCustomTracks(next);
  };

  const handleClearTracks = () => {
    setCustomTracks([]);
    syncCustomTracks([]);
  };

  const targets = state?.targets ?? [];
  const asterix = state?.asterix48 ?? [];
  const maxRangeKm = config?.max_range_km ?? 240;
  const maxRangeM = maxRangeKm * 1000;
  const customTargets = state?.custom_targets ?? [];
  const totalTargets = targets.length + customTargets.length;

  const radarPoints = useMemo(() => {
    return targets.map((target) => {
      const x = target.x_m / maxRangeM;
      const y = target.y_m / maxRangeM;
      return {
        id: target.target_id,
        x,
        y
      };
    });
  }, [targets, maxRangeM]);

  return (
    <div className="min-h-screen bg-grid">
      <div className="mx-auto max-w-7xl px-6 py-8">
        <header className="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
          <div>
            <p className="text-xs uppercase tracking-[0.3em] text-emerald-200/60">
              Phoenix
            </p>
            <h1 className="text-3xl font-semibold text-mist">Simulated Radar Targets</h1>
          </div>
          <div className="flex flex-wrap gap-3">
            <div className="rounded-full border border-emerald-200/30 px-4 py-2 text-xs text-emerald-100/70">
              PRF {config?.prf_hz ?? "-"} Hz
            </div>
            <div className="rounded-full border border-emerald-200/20 px-4 py-2 text-xs text-emerald-100/70">
              Frame {state?.frame_index ?? "-"}
            </div>
          </div>
        </header>

        <div className="mt-8 grid gap-6 lg:grid-cols-[1.1fr_1fr]">
          <section className="rounded-3xl border border-emerald-200/20 bg-slate/70 p-6 backdrop-blur">
            <div className="flex items-center justify-between">
              <div>
                <h2 className="text-lg font-semibold text-mist">Radar Scope</h2>
                <p className="text-sm text-emerald-100/60">
                  360-degree sweep with {config?.targets_per_sector ?? "-"} targets per 10 degrees.
                </p>
              </div>
              <div className="text-right text-xs text-emerald-100/70">
                <div>Max range: {maxRangeKm} km</div>
                <div>Updated: {lastUpdated ? lastUpdated.toLocaleTimeString() : "-"}</div>
              </div>
            </div>
            <div className="mt-6 flex aspect-square w-full items-center justify-center rounded-2xl border border-emerald-200/20 bg-ink/70">
              <svg viewBox="-1 -1 2 2" className="h-full w-full">
                <defs>
                  <radialGradient id="radarGlow" cx="50%" cy="50%" r="50%">
                    <stop offset="0%" stopColor="#55f2d8" stopOpacity="0.25" />
                    <stop offset="70%" stopColor="#55f2d8" stopOpacity="0.08" />
                    <stop offset="100%" stopColor="#0b1216" stopOpacity="0" />
                  </radialGradient>
                </defs>
                <circle cx="0" cy="0" r="1" fill="url(#radarGlow)" />
                {[0.25, 0.5, 0.75, 1].map((radius) => (
                  <circle
                    key={radius}
                    cx="0"
                    cy="0"
                    r={radius}
                    fill="none"
                    stroke="rgba(85, 242, 216, 0.2)"
                    strokeWidth="0.005"
                  />
                ))}
                <line
                  x1="-1"
                  y1="0"
                  x2="1"
                  y2="0"
                  stroke="rgba(85, 242, 216, 0.12)"
                  strokeWidth="0.004"
                />
                <line
                  x1="0"
                  y1="-1"
                  x2="0"
                  y2="1"
                  stroke="rgba(85, 242, 216, 0.12)"
                  strokeWidth="0.004"
                />
                <g>
                  <line
                    x1="0"
                    y1="0"
                    x2="0"
                    y2="-1"
                    stroke="rgba(85, 242, 216, 0.55)"
                    strokeWidth="0.01"
                  >
                    <animateTransform
                      attributeName="transform"
                      type="rotate"
                      from="0 0 0"
                      to="360 0 0"
                      dur="4s"
                      repeatCount="indefinite"
                    />
                  </line>
                </g>
                {radarPoints.map((point) => (
                  <circle
                    key={point.id}
                    cx={point.x}
                    cy={-point.y}
                    r={0.004}
                    fill="#55f2d8"
                    opacity="0.85"
                  />
                ))}
                {customTargets.map((target) => (
                  <circle
                    key={`custom-${target.track_id}`}
                    cx={target.x_m / maxRangeM}
                    cy={-target.y_m / maxRangeM}
                    r={0.006}
                    fill="#ff7a59"
                    opacity="0.95"
                  />
                ))}
              </svg>
            </div>
          </section>

          <section className="rounded-3xl border border-emerald-200/20 bg-slate/60 p-6">
            <h2 className="text-lg font-semibold text-mist">Target Telemetry</h2>
            <p className="text-sm text-emerald-100/60">
              Live overview of simulated detections and associated tracks.
            </p>
            <div className="mt-6 grid gap-4">
              <div className="rounded-2xl border border-emerald-200/15 bg-ink/60 p-4">
                <p className="text-xs uppercase tracking-[0.2em] text-emerald-100/60">Counts</p>
                <div className="mt-3 flex items-center justify-between text-sm text-mist">
                  <span>Total Targets</span>
                  <span className="text-emerald-200">{totalTargets}</span>
                </div>
                <div className="mt-2 flex items-center justify-between text-sm text-mist">
                  <span>ASTERIX-48 Records</span>
                  <span className="text-emerald-200">{asterix.length}</span>
                </div>
              </div>
              <div className="rounded-2xl border border-emerald-200/15 bg-ink/60 p-4">
                <p className="text-xs uppercase tracking-[0.2em] text-emerald-100/60">
                  Configuration
                </p>
                <div className="mt-3 space-y-2 text-sm text-emerald-100/70">
                  <div className="flex items-center justify-between">
                    <span>Sector Step</span>
                    <span>{config?.sector_step_deg ?? "-"} deg</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span>Targets per Sector</span>
                    <span>{config?.targets_per_sector ?? "-"}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span>RCS Range</span>
                    <span>
                      {config?.rcs_m2_range ? `${config.rcs_m2_range[0]} to ${config.rcs_m2_range[1]} m²` : "-"}
                    </span>
                  </div>
                </div>
              </div>
              <div className="rounded-2xl border border-emerald-200/15 bg-ink/60 p-4">
                <p className="text-xs uppercase tracking-[0.2em] text-emerald-100/60">Status</p>
                <div className="mt-3 space-y-2 text-sm text-emerald-100/70">
                  <div className="flex items-center justify-between">
                    <span>Backend</span>
                    <span className="text-emerald-200">{state ? "Connected" : "Waiting"}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span>API Base</span>
                    <span className="text-emerald-200">{apiBase}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span>Motion</span>
                    <button
                      type="button"
                      onClick={() => handleMotionToggle({ target: { checked: !motionEnabled } })}
                      className="rounded-full border border-emerald-200/20 bg-ink/70 px-3 py-1 text-xs text-emerald-100/80 transition hover:border-emerald-200/40 hover:text-emerald-100"
                    >
                      {motionEnabled ? "Freeze Targets" : "Enable Motion"}
                    </button>
                  </div>
                </div>
              </div>
              <div className="rounded-2xl border border-emerald-200/15 bg-ink/60 p-4">
                <p className="text-xs uppercase tracking-[0.2em] text-emerald-100/60">Custom Tracks</p>
                <div className="mt-3 space-y-3 text-sm text-emerald-100/70">
                  <div className="space-y-2">
                    <label className="block text-xs text-emerald-100/60">Platform</label>
                    <select
                      value={selectedPlatformId}
                      onChange={(event) => {
                        setSelectedPlatformId(event.target.value);
                        const platform = platforms.find(
                          (item) => String(item.id) === String(event.target.value)
                        );
                        setSelectedProfile(platform?.profiles?.[0]?.profile_name || "");
                      }}
                      className="w-full rounded-lg border border-emerald-200/20 bg-ink/80 px-3 py-2 text-xs"
                    >
                      {platforms.map((platform) => (
                        <option key={platform.id} value={platform.id}>
                          {platform.name}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div className="space-y-2">
                    <label className="block text-xs text-emerald-100/60">Profile</label>
                    <select
                      value={selectedProfile}
                      onChange={(event) => setSelectedProfile(event.target.value)}
                      className="w-full rounded-lg border border-emerald-200/20 bg-ink/80 px-3 py-2 text-xs"
                    >
                      {availableProfiles.map((profile) => (
                        <option key={profile.id} value={profile.profile_name}>
                          {profile.profile_name.charAt(0).toUpperCase() + profile.profile_name.slice(1)}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div className="grid grid-cols-3 gap-2">
                    <label className="text-xs">
                      Range (m)
                      <input
                        type="number"
                        value={rangeInput}
                        onChange={(event) => setRangeInput(event.target.value)}
                        className="mt-1 w-full rounded-lg border border-emerald-200/20 bg-ink/80 px-2 py-1 text-xs"
                      />
                    </label>
                    <label className="text-xs">
                      Azimuth (deg)
                      <input
                        type="number"
                        value={azimuthInput}
                        onChange={(event) => setAzimuthInput(event.target.value)}
                        className="mt-1 w-full rounded-lg border border-emerald-200/20 bg-ink/80 px-2 py-1 text-xs"
                      />
                    </label>
                    <label className="text-xs">
                      Heading (deg)
                      <input
                        type="number"
                        value={headingInput}
                        onChange={(event) => setHeadingInput(event.target.value)}
                        className="mt-1 w-full rounded-lg border border-emerald-200/20 bg-ink/80 px-2 py-1 text-xs"
                      />
                    </label>
                  </div>
                  <div className="flex gap-2">
                    <button
                      type="button"
                      onClick={handleAddTrack}
                      className="rounded-full border border-emerald-200/20 bg-emerald-300/10 px-3 py-1 text-xs text-emerald-100/80 transition hover:border-emerald-200/40"
                    >
                      Add Track
                    </button>
                    <button
                      type="button"
                      onClick={handleClearTracks}
                      disabled={customTracks.length === 0}
                      className="rounded-full border border-emerald-200/20 bg-ink/70 px-3 py-1 text-xs text-emerald-100/70 transition hover:border-emerald-200/40 disabled:cursor-not-allowed disabled:opacity-50"
                    >
                      Clear All Tracks
                    </button>
                  </div>
                  {customTracks.length > 0 && (
                    <div className="space-y-2 text-xs">
                      {customTracks.map((track, index) => (
                        <div
                          key={track.track_id ?? `${track.platform_id}-${index}`}
                          className="flex items-center justify-between rounded-lg border border-emerald-200/10 bg-ink/70 px-2 py-1"
                        >
                          <span>
                            {track.profile_name} @ {track.range_m}m / {track.azimuth_deg} deg
                          </span>
                          <button
                            type="button"
                            onClick={() => handleRemoveTrack(index)}
                            className="text-emerald-200/80 hover:text-emerald-100"
                          >
                            Remove
                          </button>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            </div>
          </section>
        </div>

        <section className="mt-8 rounded-3xl border border-emerald-200/20 bg-slate/70 p-6">
          <div className="flex flex-wrap items-end justify-between gap-4">
            <div>
              <h2 className="text-lg font-semibold text-mist">ASTERIX-48 Master Table</h2>
              <p className="text-sm text-emerald-100/60">
                Coordinates and characteristics formatted for CAT 048 (subset fields).
              </p>
            </div>
            <div className="text-xs text-emerald-100/60">
              Scroll to view all {asterix.length + customTargets.length} entries.
            </div>
          </div>
          <div className="mt-4 max-h-[520px] overflow-auto rounded-2xl border border-emerald-200/10">
            <table className="min-w-full text-left text-xs">
              <thead className="sticky top-0 bg-ink/90 text-emerald-200">
                <tr>
                  <th className="px-4 py-3">Track</th>
                  <th className="px-4 py-3">Polar</th>
                  <th className="px-4 py-3">Cartesian</th>
                  <th className="px-4 py-3">RCS</th>
                  <th className="px-4 py-3">Time</th>
                  <th className="px-4 py-3">CAT 048 Hex</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-emerald-200/10 text-emerald-100/70">
                {customTargets.map((target) => (
                  <tr key={`custom-${target.track_id}`} className="hover:bg-ink/70">
                    <td className="px-4 py-3 text-emerald-200">C{target.track_id}</td>
                    <td className="px-4 py-3">
                      {formatRange(target.range_m)} @ {formatAzimuth(target.azimuth_deg)}
                    </td>
                    <td className="px-4 py-3">
                      {formatNumber(target.x_m, 0)} m, {formatNumber(target.y_m, 0)} m
                    </td>
                    <td className="px-4 py-3">
                      {target.rcs_m2 === null ? "-" : `${formatNumber(target.rcs_m2, 2)} m²`}
                    </td>
                    <td className="px-4 py-3">{formatNumber(target.time_of_day_s, 2)} s</td>
                    <td className="px-4 py-3 font-mono text-[11px] text-emerald-200/80">
                      {target.raw_hex ?? "-"}
                    </td>
                  </tr>
                ))}
                {asterix.map((record) => (
                  <tr key={record.target_id} className="hover:bg-ink/70">
                    <td className="px-4 py-3 text-emerald-200">{record.track_number}</td>
                    <td className="px-4 py-3">
                      {formatRange(record.polar.range_m)} @ {formatAzimuth(record.polar.azimuth_deg)}
                    </td>
                    <td className="px-4 py-3">
                      {formatNumber(record.cartesian.x_m, 0)} m, {formatNumber(record.cartesian.y_m, 0)} m
                    </td>
                    <td className="px-4 py-3">{formatNumber(record.rcs_m2, 2)} m²</td>
                    <td className="px-4 py-3">{formatNumber(record.time_of_day_s, 2)} s</td>
                    <td className="px-4 py-3 font-mono text-[11px] text-emerald-200/80">
                      {record.raw_hex}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      </div>
    </div>
  );
}
