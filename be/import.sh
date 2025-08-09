#!/bin/bash
set -e

# Wait for Postgres to be ready
until pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"; do
  echo "Waiting for database..."
  sleep 2
done

echo "Importing GeoJSON into PostGIS..."
ogr2ogr -f "PostgreSQL" PG:"dbname=$POSTGRES_DB user=$POSTGRES_USER password=$POSTGRES_PASSWORD" \
  /docker-entrypoint-initdb.d/countries.geojson \
  -nln countries \
  -nlt MULTIPOLYGON \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -lco precision=NO

# Add spatial index
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c \
  "CREATE INDEX IF NOT EXISTS countries_geom_idx ON countries USING GIST (geom);"
