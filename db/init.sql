CREATE TABLE IF NOT EXISTS platform (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  role TEXT NOT NULL,
  source_url TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS platform_profile (
  id BIGSERIAL PRIMARY KEY,
  platform_id BIGINT NOT NULL REFERENCES platform(id) ON DELETE CASCADE,
  profile_name TEXT NOT NULL,
  speed_mps DOUBLE PRECISION NOT NULL,
  altitude_m DOUBLE PRECISION NOT NULL,
  rcs_m2_est DOUBLE PRECISION,
  rcs_quality TEXT NOT NULL DEFAULT 'estimate',
  heading_deg DOUBLE PRECISION NOT NULL DEFAULT 0,
  azimuth_deg DOUBLE PRECISION NOT NULL DEFAULT 0,
  source_url TEXT NOT NULL,
  notes TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_platform_category ON platform(category);
CREATE INDEX IF NOT EXISTS idx_platform_profile_platform ON platform_profile(platform_id);

INSERT INTO platform (name, category, role, source_url) VALUES
  ('F-16C Fighting Falcon', 'aircraft', 'multirole fighter', 'https://en.wikipedia.org/wiki/General_Dynamics_F-16_Fighting_Falcon'),
  ('F/A-18E Super Hornet', 'aircraft', 'multirole fighter', 'https://en.wikipedia.org/wiki/Boeing_F/A-18E/F_Super_Hornet'),
  ('B-52H Stratofortress', 'aircraft', 'strategic bomber', 'https://en.wikipedia.org/wiki/Boeing_B-52_Stratofortress'),
  ('C-130J Super Hercules', 'aircraft', 'tactical airlift', 'https://en.wikipedia.org/wiki/Lockheed_Martin_C-130J_Super_Hercules'),
  ('P-8A Poseidon', 'aircraft', 'maritime patrol', 'https://en.wikipedia.org/wiki/Boeing_P-8_Poseidon'),
  ('E-2D Advanced Hawkeye', 'aircraft', 'airborne early warning', 'https://en.wikipedia.org/wiki/Northrop_Grumman_E-2_Hawkeye'),
  ('Arleigh Burke-class', 'naval', 'guided-missile destroyer', 'https://en.wikipedia.org/wiki/Arleigh_Burke-class_destroyer'),
  ('Ticonderoga-class', 'naval', 'guided-missile cruiser', 'https://en.wikipedia.org/wiki/Ticonderoga-class_cruiser'),
  ('Nimitz-class', 'naval', 'aircraft carrier', 'https://en.wikipedia.org/wiki/Nimitz-class_aircraft_carrier'),
  ('Zumwalt-class', 'naval', 'guided-missile destroyer', 'https://en.wikipedia.org/wiki/Zumwalt-class_destroyer');

INSERT INTO platform_profile (platform_id, profile_name, speed_mps, altitude_m, rcs_m2_est, rcs_quality, source_url, notes) VALUES
  (1, 'Loiter', 180.0, 6000.0, 1.2, 'estimate', 'https://en.wikipedia.org/wiki/General_Dynamics_F-16_Fighting_Falcon', 'Loiter values are derived from public max and typical cruise data.'),
  (1, 'Cruise', 250.0, 9000.0, 1.2, 'estimate', 'https://en.wikipedia.org/wiki/General_Dynamics_F-16_Fighting_Falcon', 'Cruise values derived from published performance.'),
  (1, 'Max', 589.0, 15240.0, 1.2, 'estimate', 'https://en.wikipedia.org/wiki/General_Dynamics_F-16_Fighting_Falcon', 'Max speed and service ceiling from public sources.'),

  (2, 'Loiter', 170.0, 6000.0, 1.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_F/A-18E/F_Super_Hornet', 'Loiter values are derived from public max and typical cruise data.'),
  (2, 'Cruise', 240.0, 9000.0, 1.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_F/A-18E/F_Super_Hornet', 'Cruise values derived from published performance.'),
  (2, 'Max ', 532.0, 15240.0, 1.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_F/A-18E/F_Super_Hornet', 'Max speed and service ceiling from public sources.'),

  (3, 'Loiter', 180.0, 9000.0, 100.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_B-52_Stratofortress', 'Loiter values are derived from public max and typical cruise data.'),
  (3, 'Cruise', 235.0, 12000.0, 100.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_B-52_Stratofortress', 'Cruise values derived from published performance.'),
  (3, 'Max', 291.0, 15240.0, 100.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_B-52_Stratofortress', 'Max speed and service ceiling from public sources.'),

  (4, 'Loiter', 120.0, 3000.0, 40.0, 'estimate', 'https://en.wikipedia.org/wiki/Lockheed_Martin_C-130J_Super_Hercules', 'Loiter values are derived from public max and typical cruise data.'),
  (4, 'Cruise', 159.0, 6000.0, 40.0, 'estimate', 'https://en.wikipedia.org/wiki/Lockheed_Martin_C-130J_Super_Hercules', 'Cruise values derived from published performance.'),
  (4, 'Max', 183.0, 8534.0, 40.0, 'estimate', 'https://en.wikipedia.org/wiki/Lockheed_Martin_C-130J_Super_Hercules', 'Max speed and service ceiling from public sources.'),

  (5, 'Loiter', 180.0, 6000.0, 25.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_P-8_Poseidon', 'Loiter values are derived from public max and typical cruise data.'),
  (5, 'Cruise', 226.0, 9000.0, 25.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_P-8_Poseidon', 'Cruise values derived from published performance.'),
  (5, 'Max', 252.0, 12497.0, 25.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_P-8_Poseidon', 'Max speed and service ceiling from public sources.'),

  (6, 'Loiter', 140.0, 4500.0, 20.0, 'estimate', 'https://en.wikipedia.org/wiki/Northrop_Grumman_E-2_Hawkeye', 'Loiter values are derived from public max and typical cruise data.'),
  (6, 'Cruise', 154.0, 6000.0, 20.0, 'estimate', 'https://en.wikipedia.org/wiki/Northrop_Grumman_E-2_Hawkeye', 'Cruise values derived from published performance.'),
  (6, 'Max', 180.0, 10577.0, 20.0, 'estimate', 'https://en.wikipedia.org/wiki/Northrop_Grumman_E-2_Hawkeye', 'Max speed and service ceiling from public sources.'),

  (7, 'Loiter', 6.2, 0.0, 10000.0, 'estimate', 'https://en.wikipedia.org/wiki/Arleigh_Burke-class_destroyer', 'Loiter speed derived from public sources.'),
  (7, 'Cruise', 10.3, 0.0, 10000.0, 'estimate', 'https://en.wikipedia.org/wiki/Arleigh_Burke-class_destroyer', 'Cruise speed derived from public sources.'),
  (7, 'Max', 15.4, 0.0, 10000.0, 'estimate', 'https://en.wikipedia.org/wiki/Arleigh_Burke-class_destroyer', 'Max speed from public sources.'),

  (8, 'Loiter', 6.2, 0.0, 12000.0, 'estimate', 'https://en.wikipedia.org/wiki/Ticonderoga-class_cruiser', 'Loiter speed derived from public sources.'),
  (8, 'Cruise', 10.3, 0.0, 12000.0, 'estimate', 'https://en.wikipedia.org/wiki/Ticonderoga-class_cruiser', 'Cruise speed derived from public sources.'),
  (8, 'Max', 16.7, 0.0, 12000.0, 'estimate', 'https://en.wikipedia.org/wiki/Ticonderoga-class_cruiser', 'Max speed from public sources.'),

  (9, 'Loiter', 5.1, 0.0, 100000.0, 'estimate', 'https://en.wikipedia.org/wiki/Nimitz-class_aircraft_carrier', 'Loiter speed derived from public sources.'),
  (9, 'Cruise', 9.3, 0.0, 100000.0, 'estimate', 'https://en.wikipedia.org/wiki/Nimitz-class_aircraft_carrier', 'Cruise speed derived from public sources.'),
  (9, 'Max', 15.4, 0.0, 100000.0, 'estimate', 'https://en.wikipedia.org/wiki/Nimitz-class_aircraft_carrier', 'Max speed from public sources.'),

  (10, 'Loiter', 6.2, 0.0, 1000.0, 'estimate', 'https://en.wikipedia.org/wiki/Zumwalt-class_destroyer', 'Loiter speed derived from public sources.'),
  (10, 'Cruise', 10.3, 0.0, 1000.0, 'estimate', 'https://en.wikipedia.org/wiki/Zumwalt-class_destroyer', 'Cruise speed derived from public sources.'),
  (10, 'Max', 15.4, 0.0, 1000.0, 'estimate', 'https://en.wikipedia.org/wiki/Zumwalt-class_destroyer', 'Max speed from public sources.');
