FROM node:20-alpine AS build

WORKDIR /app

COPY be/api/package.json ./package.json
COPY be/api/server.js ./server.js
RUN npm install

EXPOSE 3000

CMD ["node", "server.js"]
