import express from "express";
import pkg from "pg";
import cors from "cors";

const { Pool } = pkg;

const app = express();
const pool = new Pool({
  user: process.env.POSTGRES_USER,
  host: process.env.POSTGRES_HOST,
  database: process.env.POSTGRES_DB,
  password: process.env.POSTGRES_PASSWORD,
  port: 5432,
  ssl: false,
});

app.use(
  cors({
    origin: process.env.ORIGIN,
    methods: ["GET"],
    allowedHeaders: ["Content-Type", "Accept"],
  })
);

app.get("/which-country", async (req, res) => {
  let { lat, lng } = req.query;

  lat = parseFloat(lat);
  lng = parseFloat(lng);

  if (isNaN(lat) || isNaN(lng)) {
    return res.status(400).json({ error: "lat and lng required" });
  }

  const sql = `
    SELECT name_en, ST_AsGeoJSON(geom) AS geom, country_iso, capital_city, anthem_label, anthem_audio
    FROM countries
    WHERE ST_Contains(geom, ST_SetSRID(ST_Point($1, $2), 4326))
    LIMIT 1
  `;

  try {
    const { rows } = await pool.query(sql, [lng, lat]);
    res.json({
      name: rows[0].name_en || "",
      geometry: JSON.parse(rows[0].geom),
      flag: `https://flagcdn.com/w640/${rows[0].country_iso.toLowerCase()}.png`,
      capitalCity: rows[0].capital_city || "",
      anthemAudio: rows[0].anthem_audio || "",
      anthemLabel: rows[0].anthem_label || "",
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Database error" });
  }
});

app.get("/random-country", async (req, res) => {
  const sql = `
    SELECT name_en, ST_AsGeoJSON(geom) AS geom, country_iso, capital_city, anthem_label, anthem_audio
    FROM countries
    ORDER BY random()
    LIMIT 1
  `;

  try {
    const { rows } = await pool.query(sql);
    if (!rows.length) {
      return res.status(404).json({ error: "No country found" });
    }
    res.json({
      name: rows[0].name_en || "",
      geometry: JSON.parse(rows[0].geom),
      flag: `https://flagcdn.com/w640/${rows[0].country_iso.toLowerCase()}.png`,
      capitalCity: rows[0].capital_city || "",
      anthemAudio: "",
      anthemLabel: "",
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Database error" });
  }
});

app.listen(process.env.API_PORT, "0.0.0.0", () => {
  console.log(`Server is running on http://${process.env.API_HOST}:${port}`);
});
