#!/bin/bash
set -euo pipefail
exec > /tmp/import.log 2>&1

echo "Starting import.sh at $(date)"

# Validate required env vars
for var in PGHOST PGPORT POSTGRES_USER POSTGRES_PASSWORD POSTGRES_DB; do
  if [ -z "${!var:-}" ]; then
    echo "Error: $var is not set"
    exit 1
  fi
done

echo "Connecting to DB at $PGHOST:$PGPORT..."

# Wait for Postgres to be ready
MAX_RETRIES=30
COUNT=0
until pg_isready --host="$PGHOST" --port="$PGPORT" --username="$POSTGRES_USER" --dbname="$POSTGRES_DB" > /dev/null 2>&1; do
  echo "Waiting for database... attempt $COUNT"
  sleep 2
  COUNT=$((COUNT+1))
  if [ "$COUNT" -ge "$MAX_RETRIES" ]; then
    echo "Database did not become ready in time."
    exit 1
  fi
done

echo "Database is ready. Starting GeoJSON import..."

ogr2ogr \
  -f PostgreSQL \
  PG:"dbname=$POSTGRES_DB user=$POSTGRES_USER password=$POSTGRES_PASSWORD host=$PGHOST port=$PGPORT" \
  "/tmp/countries.geojson" \
  -nln countries \
  -nlt GEOMETRY \
  -dialect SQLITE \
  -sql "SELECT
           id,
           \"name:en\" AS name_en,
           \"ISO3166-1\" AS country_iso,
           \"wikidata\" AS wikidata_country,
           geometry
         FROM countries
         WHERE \"name:en\" IS NOT NULL" \
  -lco GEOMETRY_NAME=geom \
  -lco PRECISION=NO \
  -overwrite

echo "GeoJSON import complete."
