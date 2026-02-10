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
  ('F-15C Eagle', 'aircraft', 'air superiority fighter', 'https://en.wikipedia.org/wiki/McDonnell_Douglas_F-15_Eagle'),
  ('F-15E Strike Eagle', 'aircraft', 'strike fighter', 'https://en.wikipedia.org/wiki/McDonnell_Douglas_F-15E_Strike_Eagle'),
  ('F-22 Raptor', 'aircraft', 'air superiority fighter', 'https://en.wikipedia.org/wiki/Lockheed_Martin_F-22_Raptor'),
  ('F-35 Lightning II', 'aircraft', 'multirole stealth fighter', 'https://en.wikipedia.org/wiki/Lockheed_Martin_F-35_Lightning_II'),
  ('JF-39 Gripen', 'aircraft', 'multirole fighter', 'https://en.wikipedia.org/wiki/Saab_JF-39_Gripen'),
  ('Rafale', 'aircraft', 'multirole fighter', 'https://en.wikipedia.org/wiki/Dassault_Rafale'),
  ('Eurofighter Typhoon', 'aircraft', 'air superiority fighter', 'https://en.wikipedia.org/wiki/Eurofighter_Typhoon'),
  ('B-52H Stratofortress', 'aircraft', 'strategic bomber', 'https://en.wikipedia.org/wiki/Boeing_B-52_Stratofortress'),
  ('C-130J Super Hercules', 'aircraft', 'tactical airlift', 'https://en.wikipedia.org/wiki/Lockheed_Martin_C-130J_Super_Hercules'),
  ('C-17 Globemaster III', 'aircraft', 'strategic airlift', 'https://en.wikipedia.org/wiki/Boeing_C-17_Globemaster_III'),
  ('KC-135 Stratotanker', 'aircraft', 'aerial refueling', 'https://en.wikipedia.org/wiki/Boeing_KC-135_Stratotanker'),
  ('KC-10 Extender', 'aircraft', 'aerial refueling', 'https://en.wikipedia.org/wiki/McDonnell_Douglas_KC-10_Extender'),
  ('E-3 Sentry', 'aircraft', 'airborne early warning', 'https://en.wikipedia.org/wiki/Boeing_E-3_Sentry'),
  ('E-2D Advanced Hawkeye', 'aircraft', 'airborne early warning', 'https://en.wikipedia.org/wiki/Northrop_Grumman_E-2_Hawkeye'),
  ('E-8 JSTARS', 'aircraft', 'airborne battle management', 'https://en.wikipedia.org/wiki/Northrop_Grumman_E-8_JSTARS'),
  ('P-8A Poseidon', 'aircraft', 'maritime patrol', 'https://en.wikipedia.org/wiki/Boeing_P-8_Poseidon'),
  ('P-3C Orion', 'aircraft', 'maritime patrol', 'https://en.wikipedia.org/wiki/Lockheed_P-3_Orion'),
  ('AH-64 Apache', 'aircraft', 'attack helicopter', 'https://en.wikipedia.org/wiki/Boeing_AH-64_Apache'),
  ('UH-60 Black Hawk', 'aircraft', 'transport helicopter', 'https://en.wikipedia.org/wiki/Sikorsky_UH-60_Black_Hawk'),
  ('CH-47 Chinook', 'aircraft', 'heavy-lift helicopter', 'https://en.wikipedia.org/wiki/Boeing_CH-47_Chinook'),
  ('MH-60 Seahawk', 'aircraft', 'naval helicopter', 'https://en.wikipedia.org/wiki/Sikorsky_MH-60_Seahawk'),
  ('AH-1Z Viper', 'aircraft', 'attack helicopter', 'https://en.wikipedia.org/wiki/Bell_AH-1Z_Viper'),
  ('Arleigh Burke-class', 'naval', 'guided-missile destroyer', 'https://en.wikipedia.org/wiki/Arleigh_Burke-class_destroyer'),
  ('Ticonderoga-class', 'naval', 'guided-missile cruiser', 'https://en.wikipedia.org/wiki/Ticonderoga-class_cruiser'),
  ('Oliver Hazard Perry-class', 'naval', 'guided-missile frigate', 'https://en.wikipedia.org/wiki/Oliver_Hazard_Perry-class_frigate'),
  ('Constellation-class', 'naval', 'frigate', 'https://en.wikipedia.org/wiki/Constellation-class_frigate'),
  ('Independence-class', 'naval', 'littoral combat ship', 'https://en.wikipedia.org/wiki/Independence-class_littoral_combat_ship'),
  ('Nimitz-class', 'naval', 'aircraft carrier', 'https://en.wikipedia.org/wiki/Nimitz-class_aircraft_carrier'),
  ('Gerald R. Ford-class', 'naval', 'aircraft carrier', 'https://en.wikipedia.org/wiki/Gerald_R._Ford-class_carrier'),
  ('Zumwalt-class', 'naval', 'guided-missile destroyer', 'https://en.wikipedia.org/wiki/Zumwalt-class_destroyer'),
  ('Akizuki-class', 'naval', 'guided-missile destroyer', 'https://en.wikipedia.org/wiki/Akizuki-class_destroyer'),
  ('Kongo-class', 'naval', 'guided-missile destroyer', 'https://en.wikipedia.org/wiki/Kongo-class_destroyer'),
  ('Type 45 Daring-class', 'naval', 'air-defense destroyer', 'https://en.wikipedia.org/wiki/Type_45_destroyer');

INSERT INTO platform_profile (platform_id, profile_name, speed_mps, altitude_m, rcs_m2_est, rcs_quality, source_url, notes) VALUES
  (1, 'Loiter', 180.0, 6000.0, 1.2, 'estimate', 'https://en.wikipedia.org/wiki/General_Dynamics_F-16_Fighting_Falcon', 'Loiter values derived from public max and typical cruise data.'),
  (1, 'Cruise', 250.0, 9000.0, 1.2, 'estimate', 'https://en.wikipedia.org/wiki/General_Dynamics_F-16_Fighting_Falcon', 'Cruise values derived from published performance.'),
  (1, 'Max', 589.0, 15240.0, 1.2, 'estimate', 'https://en.wikipedia.org/wiki/General_Dynamics_F-16_Fighting_Falcon', 'Max speed and service ceiling from public sources.'),
  
  (2, 'Loiter', 170.0, 6000.0, 1.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_F/A-18E/F_Super_Hornet', 'Loiter values derived from public max and typical cruise data.'),
  (2, 'Cruise', 240.0, 9000.0, 1.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_F/A-18E/F_Super_Hornet', 'Cruise values derived from published performance.'),
  (2, 'Max', 532.0, 15240.0, 1.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_F/A-18E/F_Super_Hornet', 'Max speed and service ceiling from public sources.'),

  (3, 'Loiter', 180.0, 7000.0, 1.5, 'estimate', 'https://en.wikipedia.org/wiki/McDonnell_Douglas_F-15_Eagle', 'Loiter values derived from cruise data.'),
  (3, 'Cruise', 260.0, 10000.0, 1.5, 'estimate', 'https://en.wikipedia.org/wiki/McDonnell_Douglas_F-15_Eagle', 'Cruise values derived from published performance.'),
  (3, 'Max', 595.0, 15240.0, 1.5, 'estimate', 'https://en.wikipedia.org/wiki/McDonnell_Douglas_F-15_Eagle', 'Max speed and service ceiling from public sources.'),

  (4, 'Loiter', 180.0, 7000.0, 1.5, 'estimate', 'https://en.wikipedia.org/wiki/McDonnell_Douglas_F-15E_Strike_Eagle', 'Loiter values derived from cruise data.'),
  (4, 'Cruise', 260.0, 10000.0, 1.5, 'estimate', 'https://en.wikipedia.org/wiki/McDonnell_Douglas_F-15E_Strike_Eagle', 'Cruise values derived from published performance.'),
  (4, 'Max', 595.0, 15240.0, 1.5, 'estimate', 'https://en.wikipedia.org/wiki/McDonnell_Douglas_F-15E_Strike_Eagle', 'Max speed and service ceiling from public sources.'),

  (5, 'Loiter', 150.0, 8000.0, 0.05, 'estimate', 'https://en.wikipedia.org/wiki/Lockheed_Martin_F-22_Raptor', 'Loiter values derived from cruise data, stealth design.'),
  (5, 'Cruise', 230.0, 12000.0, 0.05, 'estimate', 'https://en.wikipedia.org/wiki/Lockheed_Martin_F-22_Raptor', 'Cruise values derived from published performance.'),
  (5, 'Max', 591.0, 15240.0, 0.05, 'estimate', 'https://en.wikipedia.org/wiki/Lockheed_Martin_F-22_Raptor', 'Max speed and service ceiling, stealth aircraft.'),

  (6, 'Loiter', 150.0, 7000.0, 0.01, 'estimate', 'https://en.wikipedia.org/wiki/Lockheed_Martin_F-35_Lightning_II', 'Loiter values derived from cruise data, stealth design.'),
  (6, 'Cruise', 220.0, 10000.0, 0.01, 'estimate', 'https://en.wikipedia.org/wiki/Lockheed_Martin_F-35_Lightning_II', 'Cruise values derived from published performance.'),
  (6, 'Max', 558.0, 15240.0, 0.01, 'estimate', 'https://en.wikipedia.org/wiki/Lockheed_Martin_F-35_Lightning_II', 'Max speed and service ceiling, stealth aircraft.'),

  (7, 'Loiter', 170.0, 6000.0, 1.0, 'estimate', 'https://en.wikipedia.org/wiki/Saab_JF-39_Gripen', 'Loiter values derived from cruise data.'),
  (7, 'Cruise', 240.0, 9000.0, 1.0, 'estimate', 'https://en.wikipedia.org/wiki/Saab_JF-39_Gripen', 'Cruise values derived from published performance.'),
  (7, 'Max', 540.0, 15240.0, 1.0, 'estimate', 'https://en.wikipedia.org/wiki/Saab_JF-39_Gripen', 'Max speed and service ceiling from public sources.'),

  (8, 'Loiter', 160.0, 6000.0, 1.2, 'estimate', 'https://en.wikipedia.org/wiki/Dassault_Rafale', 'Loiter values derived from cruise data.'),
  (8, 'Cruise', 230.0, 9000.0, 1.2, 'estimate', 'https://en.wikipedia.org/wiki/Dassault_Rafale', 'Cruise values derived from published performance.'),
  (8, 'Max', 552.0, 16760.0, 1.2, 'estimate', 'https://en.wikipedia.org/wiki/Dassault_Rafale', 'Max speed and service ceiling from public sources.'),

  (9, 'Loiter', 170.0, 6000.0, 1.5, 'estimate', 'https://en.wikipedia.org/wiki/Eurofighter_Typhoon', 'Loiter values derived from cruise data.'),
  (9, 'Cruise', 240.0, 9000.0, 1.5, 'estimate', 'https://en.wikipedia.org/wiki/Eurofighter_Typhoon', 'Cruise values derived from published performance.'),
  (9, 'Max', 570.0, 15240.0, 1.5, 'estimate', 'https://en.wikipedia.org/wiki/Eurofighter_Typhoon', 'Max speed and service ceiling from public sources.'),

  (10, 'Loiter', 180.0, 9000.0, 100.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_B-52_Stratofortress', 'Loiter values derived from cruise data.'),
  (10, 'Cruise', 235.0, 12000.0, 100.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_B-52_Stratofortress', 'Cruise values derived from published performance.'),
  (10, 'Max', 291.0, 15240.0, 100.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_B-52_Stratofortress', 'Max speed and service ceiling from public sources.'),

  (11, 'Loiter', 120.0, 3000.0, 40.0, 'estimate', 'https://en.wikipedia.org/wiki/Lockheed_Martin_C-130J_Super_Hercules', 'Loiter values derived from cruise data.'),
  (11, 'Cruise', 159.0, 6000.0, 40.0, 'estimate', 'https://en.wikipedia.org/wiki/Lockheed_Martin_C-130J_Super_Hercules', 'Cruise values derived from published performance.'),
  (11, 'Max', 183.0, 8534.0, 40.0, 'estimate', 'https://en.wikipedia.org/wiki/Lockheed_Martin_C-130J_Super_Hercules', 'Max speed and service ceiling from public sources.'),

  (12, 'Loiter', 150.0, 6000.0, 60.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_C-17_Globemaster_III', 'Loiter values derived from cruise data.'),
  (12, 'Cruise', 230.0, 9000.0, 60.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_C-17_Globemaster_III', 'Cruise values derived from published performance.'),
  (12, 'Max', 266.0, 13106.0, 60.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_C-17_Globemaster_III', 'Max speed and service ceiling from public sources.'),

  (13, 'Loiter', 140.0, 6000.0, 60.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_KC-135_Stratotanker', 'Loiter values derived from cruise data.'),
  (13, 'Cruise', 210.0, 9000.0, 60.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_KC-135_Stratotanker', 'Cruise values derived from published performance.'),
  (13, 'Max', 270.0, 12500.0, 60.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_KC-135_Stratotanker', 'Max speed and service ceiling from public sources.'),

  (14, 'Loiter', 150.0, 6000.0, 75.0, 'estimate', 'https://en.wikipedia.org/wiki/McDonnell_Douglas_KC-10_Extender', 'Loiter values derived from cruise data.'),
  (14, 'Cruise', 230.0, 9000.0, 75.0, 'estimate', 'https://en.wikipedia.org/wiki/McDonnell_Douglas_KC-10_Extender', 'Cruise values derived from published performance.'),
  (14, 'Max', 270.0, 12500.0, 75.0, 'estimate', 'https://en.wikipedia.org/wiki/McDonnell_Douglas_KC-10_Extender', 'Max speed and service ceiling from public sources.'),

  (15, 'Loiter', 140.0, 6000.0, 80.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_E-3_Sentry', 'Loiter values derived from cruise data.'),
  (15, 'Cruise', 210.0, 9000.0, 80.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_E-3_Sentry', 'Cruise values derived from published performance.'),
  (15, 'Max', 285.0, 12500.0, 80.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_E-3_Sentry', 'Max speed and service ceiling from public sources.'),

  (16, 'Loiter', 140.0, 4500.0, 20.0, 'estimate', 'https://en.wikipedia.org/wiki/Northrop_Grumman_E-2_Hawkeye', 'Loiter values derived from cruise data.'),
  (16, 'Cruise', 154.0, 6000.0, 20.0, 'estimate', 'https://en.wikipedia.org/wiki/Northrop_Grumman_E-2_Hawkeye', 'Cruise values derived from published performance.'),
  (16, 'Max', 180.0, 10577.0, 20.0, 'estimate', 'https://en.wikipedia.org/wiki/Northrop_Grumman_E-2_Hawkeye', 'Max speed and service ceiling from public sources.'),

  (17, 'Loiter', 140.0, 6000.0, 100.0, 'estimate', 'https://en.wikipedia.org/wiki/Northrop_Grumman_E-8_JSTARS', 'Loiter values derived from cruise data.'),
  (17, 'Cruise', 210.0, 9000.0, 100.0, 'estimate', 'https://en.wikipedia.org/wiki/Northrop_Grumman_E-8_JSTARS', 'Cruise values derived from published performance.'),
  (17, 'Max', 285.0, 12500.0, 100.0, 'estimate', 'https://en.wikipedia.org/wiki/Northrop_Grumman_E-8_JSTARS', 'Max speed and service ceiling from public sources.'),

  (18, 'Loiter', 180.0, 6000.0, 25.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_P-8_Poseidon', 'Loiter values derived from cruise data.'),
  (18, 'Cruise', 226.0, 9000.0, 25.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_P-8_Poseidon', 'Cruise values derived from published performance.'),
  (18, 'Max', 252.0, 12497.0, 25.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_P-8_Poseidon', 'Max speed and service ceiling from public sources.'),

  (19, 'Loiter', 150.0, 6000.0, 30.0, 'estimate', 'https://en.wikipedia.org/wiki/Lockheed_P-3_Orion', 'Loiter values derived from cruise data.'),
  (19, 'Cruise', 190.0, 8000.0, 30.0, 'estimate', 'https://en.wikipedia.org/wiki/Lockheed_P-3_Orion', 'Cruise values derived from published performance.'),
  (19, 'Max', 220.0, 11278.0, 30.0, 'estimate', 'https://en.wikipedia.org/wiki/Lockheed_P-3_Orion', 'Max speed and service ceiling from public sources.'),

  (20, 'Loiter', 50.0, 1500.0, 5.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_AH-64_Apache', 'Loiter values derived from cruise data, rotorcraft.'),
  (20, 'Cruise', 70.0, 3000.0, 5.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_AH-64_Apache', 'Cruise values derived from published performance.'),
  (20, 'Max', 95.0, 4800.0, 5.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_AH-64_Apache', 'Max speed and service ceiling, rotorcraft.'),

  (21, 'Loiter', 45.0, 1500.0, 8.0, 'estimate', 'https://en.wikipedia.org/wiki/Sikorsky_UH-60_Black_Hawk', 'Loiter values derived from cruise data, rotorcraft.'),
  (21, 'Cruise', 70.0, 3000.0, 8.0, 'estimate', 'https://en.wikipedia.org/wiki/Sikorsky_UH-60_Black_Hawk', 'Cruise values derived from published performance.'),
  (21, 'Max', 96.0, 5486.0, 8.0, 'estimate', 'https://en.wikipedia.org/wiki/Sikorsky_UH-60_Black_Hawk', 'Max speed and service ceiling, rotorcraft.'),

  (22, 'Loiter', 50.0, 1500.0, 10.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_CH-47_Chinook', 'Loiter values derived from cruise data, rotorcraft.'),
  (22, 'Cruise', 70.0, 3000.0, 10.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_CH-47_Chinook', 'Cruise values derived from published performance.'),
  (22, 'Max', 96.0, 5950.0, 10.0, 'estimate', 'https://en.wikipedia.org/wiki/Boeing_CH-47_Chinook', 'Max speed and service ceiling, rotorcraft.'),

  (23, 'Loiter', 45.0, 1500.0, 5.0, 'estimate', 'https://en.wikipedia.org/wiki/Sikorsky_MH-60_Seahawk', 'Loiter values derived from cruise data, rotorcraft.'),
  (23, 'Cruise', 65.0, 3000.0, 5.0, 'estimate', 'https://en.wikipedia.org/wiki/Sikorsky_MH-60_Seahawk', 'Cruise values derived from published performance.'),
  (23, 'Max', 92.0, 5790.0, 5.0, 'estimate', 'https://en.wikipedia.org/wiki/Sikorsky_MH-60_Seahawk', 'Max speed and service ceiling, rotorcraft.'),

  (24, 'Loiter', 50.0, 1500.0, 8.0, 'estimate', 'https://en.wikipedia.org/wiki/Bell_AH-1Z_Viper', 'Loiter values derived from cruise data, rotorcraft.'),
  (24, 'Cruise', 70.0, 3000.0, 8.0, 'estimate', 'https://en.wikipedia.org/wiki/Bell_AH-1Z_Viper', 'Cruise values derived from published performance.'),
  (24, 'Max', 93.0, 5486.0, 8.0, 'estimate', 'https://en.wikipedia.org/wiki/Bell_AH-1Z_Viper', 'Max speed and service ceiling, rotorcraft.'),

  (25, 'Loiter', 6.2, 0.0, 10000.0, 'estimate', 'https://en.wikipedia.org/wiki/Arleigh_Burke-class_destroyer', 'Loiter speed derived from public sources.'),
  (25, 'Cruise', 10.3, 0.0, 10000.0, 'estimate', 'https://en.wikipedia.org/wiki/Arleigh_Burke-class_destroyer', 'Cruise speed derived from public sources.'),
  (25, 'Max', 15.4, 0.0, 10000.0, 'estimate', 'https://en.wikipedia.org/wiki/Arleigh_Burke-class_destroyer', 'Max speed from public sources.'),

  (26, 'Loiter', 6.2, 0.0, 12000.0, 'estimate', 'https://en.wikipedia.org/wiki/Ticonderoga-class_cruiser', 'Loiter speed derived from public sources.'),
  (26, 'Cruise', 10.3, 0.0, 12000.0, 'estimate', 'https://en.wikipedia.org/wiki/Ticonderoga-class_cruiser', 'Cruise speed derived from public sources.'),
  (26, 'Max', 16.7, 0.0, 12000.0, 'estimate', 'https://en.wikipedia.org/wiki/Ticonderoga-class_cruiser', 'Max speed from public sources.'),

  (27, 'Loiter', 5.1, 0.0, 6000.0, 'estimate', 'https://en.wikipedia.org/wiki/Oliver_Hazard_Perry-class_frigate', 'Loiter speed derived from public sources.'),
  (27, 'Cruise', 8.2, 0.0, 6000.0, 'estimate', 'https://en.wikipedia.org/wiki/Oliver_Hazard_Perry-class_frigate', 'Cruise speed derived from public sources.'),
  (27, 'Max', 13.4, 0.0, 6000.0, 'estimate', 'https://en.wikipedia.org/wiki/Oliver_Hazard_Perry-class_frigate', 'Max speed from public sources.'),

  (28, 'Loiter', 5.1, 0.0, 8000.0, 'estimate', 'https://en.wikipedia.org/wiki/Constellation-class_frigate', 'Loiter speed derived from public sources.'),
  (28, 'Cruise', 9.3, 0.0, 8000.0, 'estimate', 'https://en.wikipedia.org/wiki/Constellation-class_frigate', 'Cruise speed derived from public sources.'),
  (28, 'Max', 13.4, 0.0, 8000.0, 'estimate', 'https://en.wikipedia.org/wiki/Constellation-class_frigate', 'Max speed from public sources.'),

  (29, 'Loiter', 5.1, 0.0, 5000.0, 'estimate', 'https://en.wikipedia.org/wiki/Independence-class_littoral_combat_ship', 'Loiter speed derived from public sources.'),
  (29, 'Cruise', 9.3, 0.0, 5000.0, 'estimate', 'https://en.wikipedia.org/wiki/Independence-class_littoral_combat_ship', 'Cruise speed derived from public sources.'),
  (29, 'Max', 13.9, 0.0, 5000.0, 'estimate', 'https://en.wikipedia.org/wiki/Independence-class_littoral_combat_ship', 'Max speed from public sources.'),

  (30, 'Loiter', 5.1, 0.0, 100000.0, 'estimate', 'https://en.wikipedia.org/wiki/Nimitz-class_aircraft_carrier', 'Loiter speed derived from public sources.'),
  (30, 'Cruise', 9.3, 0.0, 100000.0, 'estimate', 'https://en.wikipedia.org/wiki/Nimitz-class_aircraft_carrier', 'Cruise speed derived from public sources.'),
  (30, 'Max', 15.4, 0.0, 100000.0, 'estimate', 'https://en.wikipedia.org/wiki/Nimitz-class_aircraft_carrier', 'Max speed from public sources.'),

  (31, 'Loiter', 5.1, 0.0, 100000.0, 'estimate', 'https://en.wikipedia.org/wiki/Gerald_R._Ford-class_carrier', 'Loiter speed derived from public sources.'),
  (31, 'Cruise', 9.3, 0.0, 100000.0, 'estimate', 'https://en.wikipedia.org/wiki/Gerald_R._Ford-class_carrier', 'Cruise speed derived from public sources.'),
  (31, 'Max', 15.4, 0.0, 100000.0, 'estimate', 'https://en.wikipedia.org/wiki/Gerald_R._Ford-class_carrier', 'Max speed from public sources.'),

  (32, 'Loiter', 6.2, 0.0, 1000.0, 'estimate', 'https://en.wikipedia.org/wiki/Zumwalt-class_destroyer', 'Loiter speed derived from public sources.'),
  (32, 'Cruise', 10.3, 0.0, 1000.0, 'estimate', 'https://en.wikipedia.org/wiki/Zumwalt-class_destroyer', 'Cruise speed derived from public sources.'),
  (32, 'Max', 15.4, 0.0, 1000.0, 'estimate', 'https://en.wikipedia.org/wiki/Zumwalt-class_destroyer', 'Max speed from public sources.'),

  (33, 'Loiter', 5.1, 0.0, 9000.0, 'estimate', 'https://en.wikipedia.org/wiki/Akizuki-class_destroyer', 'Loiter speed derived from public sources.'),
  (33, 'Cruise', 8.2, 0.0, 9000.0, 'estimate', 'https://en.wikipedia.org/wiki/Akizuki-class_destroyer', 'Cruise speed derived from public sources.'),
  (33, 'Max', 13.4, 0.0, 9000.0, 'estimate', 'https://en.wikipedia.org/wiki/Akizuki-class_destroyer', 'Max speed from public sources.'),

  (34, 'Loiter', 5.1, 0.0, 11000.0, 'estimate', 'https://en.wikipedia.org/wiki/Kongo-class_destroyer', 'Loiter speed derived from public sources.'),
  (34, 'Cruise', 8.2, 0.0, 11000.0, 'estimate', 'https://en.wikipedia.org/wiki/Kongo-class_destroyer', 'Cruise speed derived from public sources.'),
  (34, 'Max', 13.4, 0.0, 11000.0, 'estimate', 'https://en.wikipedia.org/wiki/Kongo-class_destroyer', 'Max speed from public sources.'),

  (35, 'Loiter', 5.1, 0.0, 9500.0, 'estimate', 'https://en.wikipedia.org/wiki/Type_45_destroyer', 'Loiter speed derived from public sources.'),
  (35, 'Cruise', 8.2, 0.0, 9500.0, 'estimate', 'https://en.wikipedia.org/wiki/Type_45_destroyer', 'Cruise speed derived from public sources.'),
  (35, 'Max', 13.4, 0.0, 9500.0, 'estimate', 'https://en.wikipedia.org/wiki/Type_45_destroyer', 'Max speed from public sources.');
