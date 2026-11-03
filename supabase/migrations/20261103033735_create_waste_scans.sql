/*
# Create waste_scans table (public, no sign-in)

1. New Tables
- `waste_scans`
  - `id` (uuid, primary key)
  - `regency` (text, not null) - Bali regency where the scan happened (e.g. Denpasar)
  - `village` (text, not null) - village or district within the regency
  - `category` (text, not null) - one of: organic, inorganic, residue
  - `confidence` (numeric, 0-100) - classifier confidence percentage
  - `thumbnail` (text, optional) - small compressed image preview stored as a data URL
  - `created_at` (timestamptz) - when the scan was recorded

2. Security
- Row level security enabled on `waste_scans`.
- The app has no sign-in, so `anon` and `authenticated` are granted SELECT and INSERT only.
- No UPDATE or DELETE access is granted to any client role, so scan logs cannot be altered from the browser.

3. Important Notes
- 1. Indexes are added on created_at, regency and category to keep dashboard filters fast.
- 2. Thumbnails are capped at roughly 60 KB of text to keep rows small.
*/

CREATE TABLE IF NOT EXISTS waste_scans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  regency text NOT NULL,
  village text NOT NULL,
  category text NOT NULL CHECK (category IN ('organic', 'inorganic', 'residue')),
  confidence numeric(5,2) NOT NULL CHECK (confidence >= 0 AND confidence <= 100),
  thumbnail text CHECK (thumbnail IS NULL OR length(thumbnail) <= 60000),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS waste_scans_created_at_idx ON waste_scans (created_at DESC);
CREATE INDEX IF NOT EXISTS waste_scans_regency_idx ON waste_scans (regency);
CREATE INDEX IF NOT EXISTS waste_scans_category_idx ON waste_scans (category);

ALTER TABLE waste_scans ENABLE ROW LEVEL SECURITY;

GRANT SELECT, INSERT ON waste_scans TO anon, authenticated;

DROP POLICY IF EXISTS "anon_select_waste_scans" ON waste_scans;
CREATE POLICY "anon_select_waste_scans" ON waste_scans FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_waste_scans" ON waste_scans;
CREATE POLICY "anon_insert_waste_scans" ON waste_scans FOR INSERT
  TO anon, authenticated WITH CHECK (true);
