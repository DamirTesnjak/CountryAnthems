#!/bin/bash
set -e

echo "Running import.sh..."

# Wait for Postgres to be ready
until pg_isready \
  --host="$PGHOST" \
  --port="$PGPORT" \
  --username="$POSTGRES_USER" \
  --dbname="$POSTGRES_DB"
do
  echo "Waiting for database..."
  sleep 2
done

# Import GeoJSON using ogr2ogr
ogr2ogr \
  -f PostgreSQL \
  PG:"dbname=$POSTGRES_DB \
      user=$POSTGRES_USER \
      password=$POSTGRES_PASSWORD \
      host=$PGHOST \
      port=$PGPORT" \
  "${path.module}/migrations/countries.geojson" \
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
