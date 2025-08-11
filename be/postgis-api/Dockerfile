FROM postgis/postgis:15-3.4

RUN apt-get update && \
    apt-get install -y gdal-bin curl gnupg && \
    rm -rf /var/lib/apt/lists/*

# Copy database init files
WORKDIR /app
COPY be/postgis-api/countries.geojson /docker-entrypoint-initdb.d/countries.geojson
COPY be/postgis-api/init.sql /docker-entrypoint-initdb.d/init.sql
COPY be/postgis-api/import.sh /docker-entrypoint-initdb.d/import.sh
RUN chmod +x /docker-entrypoint-initdb.d/import.sh

EXPOSE 5432

# Start both Postgres and Node API in one container
CMD ["postgres"]
