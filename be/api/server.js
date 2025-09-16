import express from "express";
import pkg from "pg";
import cors from "cors";
import os from "os";

const { Pool } = pkg;

const app = express();

const pool = new Pool({
  user: process.env.POSTGRES_USER,
  host: process.env.POSTGRES_HOST,
  database: process.env.POSTGRES_DB,
  password: process.env.POSTGRES_PASSWORD,
  port: 5432,
  ssl: {
    rejectUnauthorized: false,
    sslmode: "prefer",
  },
});

console.log("Database config loaded:", {
  user: process.env.POSTGRES_USER,
  host: process.env.POSTGRES_HOST,
  origin: process.env.ORIGIN,
  database: process.env.POSTGRES_DB,
});

app.use(
  cors({
    origin: process.env.ORIGIN,
    methods: ["GET"],
    allowedHeaders: ["Content-Type", "Accept"],
  })
);

app.get("/", (req, res) => {
  console.log("Health check requested from:", req.ip);
  res.status(200).json({
    status: "healthy",
    timestamp: new Date().toISOString(),
    service: "country-anthems-api",
  });
});

app.get("/api/which-country", async (req, res) => {
  console.log("req.query →", req.url);
  const rawQs = req._parsedUrl?.query || "";
  const params = new URLSearchParams(rawQs);

  const lat = parseFloat(params.get("lat") || "");
  const lng = parseFloat(params.get("lng") || "");

  console.log("coordinates, lat, lng", [lat, lng]);

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
    console.log("rows", rows);
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

app.get("/api/random-country", async (req, res) => {
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

const API_PORT = process.env.API_PORT || 5001;
const API_HOST = process.env.API_HOST || "0.0.0.0";

app.listen(API_PORT, API_HOST, () => {
  console.log(`Server is running on http://${API_HOST}:${API_PORT}`);

  // Optional: Also log the actual container IP for debugging
  const networkInterfaces = os.networkInterfaces();
  const containerIP = networkInterfaces.eth0?.[0]?.address;
  if (containerIP) {
    console.log(`Container accessible at: http://${containerIP}:${API_PORT}`);
  }
});
