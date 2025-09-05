ALTER TABLE countries ADD COLUMN IF NOT EXISTS capital_city TEXT;
ALTER TABLE countries ADD COLUMN IF NOT EXISTS anthem_label TEXT;
ALTER TABLE countries ADD COLUMN IF NOT EXISTS anthem_audio TEXT;

DROP TABLE IF EXISTS country_extra;
CREATE TABLE country_extra (
    country_wiki_data TEXT,
    country_label TEXT,
    capital_wiki_data TEXT,
    capital_label TEXT,
    anthem TEXT,
    anthem_label TEXT,
    anthem_audio TEXT
);

CREATE TEMP TABLE capitals_raw(json_text text);

\copy capitals_raw FROM '__DATA_PATH__'

INSERT INTO country_extra(country_wiki_data, country_label, capital_wiki_data, capital_label, anthem, anthem_label, anthem_audio)
SELECT
    elem->>'country' AS country_wiki_data,
    elem->>'countryLabel' AS country_label,
    elem->>'capital' AS capital_wiki_data,
    elem->>'capitalLabel' AS capital_label,
    elem->>'anthem' AS anthem,
    elem->>'anthemLabel' AS anthem_label,
    elem->>'anthemAudio' AS anthem_audio
FROM (
    SELECT json_array_elements(json_text::json) AS elem
    FROM capitals_raw
) t;

UPDATE countries c
SET 
    capital_city = e.capital_label,
    anthem_label = e.anthem_label,
    anthem_audio = e.anthem_audio
FROM country_extra e
WHERE c.wikidata_country = e.country_wiki_data;
