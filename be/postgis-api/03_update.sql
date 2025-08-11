-- 1. Add new column to countries table
ALTER TABLE countries ADD COLUMN IF NOT EXISTS capital_city TEXT;

-- 2. Create country_extra table
DROP TABLE IF EXISTS country_extra;
CREATE TABLE country_extra (
    country_wiki_data TEXT,
    country_label TEXT,
    capital_wiki_data TEXT,
    capital_label TEXT
);

-- 3. Staging table for raw JSON file
CREATE TEMP TABLE capitals_raw(json_text text);

-- 4. Load file from /docker-entrypoint-initdb.d into staging table
-- This will be run automatically by Docker init scripts if file exists in the same dir
\copy capitals_raw FROM '/docker-entrypoint-initdb.d/capitalCities.json'

-- 5. Parse JSON and insert into country_extra
INSERT INTO country_extra(country_wiki_data, country_label, capital_wiki_data, capital_label)
SELECT
    elem->>'country' AS country_wiki_data,
    elem->>'countryLabel' AS country_label,
    elem->>'capital' AS capital_wiki_data,
    elem->>'capitalLabel' AS capital_label
FROM (
    SELECT json_array_elements(json_text::json) AS elem
    FROM capitals_raw
) t;

-- 6. Update countries table
UPDATE countries c
SET capital_city = e.capital_label
FROM country_extra e
WHERE c.wikidata_country = e.country_wiki_data;