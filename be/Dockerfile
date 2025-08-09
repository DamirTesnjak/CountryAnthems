FROM postgis/postgis:15-3.4

RUN apt-get update && \
    apt-get install -y gdal-bin curl && rm -rf /var/lib/apt/lists/*

# Copy database init files
COPY countries.geojson /docker-entrypoint-initdb.d/countries.geojson
COPY docker-entrypoint-initdb.d/init.sql /docker-entrypoint-initdb.d/init.sql
COPY docker-entrypoint-initdb.d/import.sh /docker-entrypoint-initdb.d/import.sh
RUN chmod +x /docker-entrypoint-initdb.d/import.sh

# Copy Node.js API files
COPY package.json /app/package.json
COPY server.js /app/server.js
WORKDIR /app
RUN npm install

# Expose ports: 5432 for Postgres, 3000 for API
EXPOSE 5432 3000

# Start both Postgres and Node API in one container
CMD service postgresql start && \
    node /app/server.js && \
    tail -f /dev/null
