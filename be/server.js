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
});

app.get("/which-country", async (req, res) => {
  const { lat, lon } = req.query;
  if (!lat || !lon) {
    return res.status(400).json({ error: "lat and lon required" });
  }

  const sql = `
    SELECT name, "ISO3166-1" AS iso,
           'https://flagcdn.com/' || lower("ISO3166-1") || '.svg' AS flag
    FROM countries
    WHERE ST_Contains(geom, ST_SetSRID(ST_Point($1, $2), 4326))
    LIMIT 1
  `;

  try {
    const { rows } = await pool.query(sql, [lon, lat]);
    res.json(rows[0] || {});
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Database error" });
  }
});

app.listen(3000, () => {
  console.log("API running on port 3000");
});
