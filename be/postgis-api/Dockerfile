FROM postgis/postgis:15-3.4

RUN apt-get update && \
    apt-get install -y gdal-bin curl gnupg && \
    rm -rf /var/lib/apt/lists/*

# Copy database init files
WORKDIR /app
COPY be/postgis-api/countries.geojson /docker-entrypoint-initdb.d/countries.geojson
COPY be/postgis-api/01_init.sql /docker-entrypoint-initdb.d/01_init.sql
COPY be/postgis-api/02_import.sh /docker-entrypoint-initdb.d/02_import.sh
COPY be/postgis-api/capitalCities.json /docker-entrypoint-initdb.d/capitalCities.json
COPY be/postgis-api/03_update.sql /docker-entrypoint-initdb.d/03_update.sql
RUN chmod +x /docker-entrypoint-initdb.d/02_import.sh

EXPOSE 5432

# Start both Postgres and Node API in one container
CMD ["postgres"]
