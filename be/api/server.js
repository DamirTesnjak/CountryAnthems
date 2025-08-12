import express from "express";
import pkg from "pg";

const { Pool } = pkg;

const app = express();
const pool = new Pool({
  user: process.env.POSTGRES_USER || "postgres",
  host: "localhost",
  database: process.env.POSTGRES_DB || "geo",
  password: process.env.POSTGRES_PASSWORD || "postgres",
  port: 5432,
  ssl: false,
});

app.use(setCorsHeaders);

function setCorsHeaders(req, res, next) {
  res.setHeader("Access-Control-Allow-Origin", "http://localhost:4200");
  res.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    return res.sendStatus(200);
  }
  next();
}

app.get("/which-country", async (req, res) => {
  console.log("req", req.query);
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
      anthemLabel: rows[0].anthem_label,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Database error" });
  }
});

const port = 3000;
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
