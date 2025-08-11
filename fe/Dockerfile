# Stage 1: Build Angular app
FROM node:20-alpine AS build

WORKDIR /app

COPY frontend/package*.json ./
RUN npm ci

COPY frontend ./

RUN npm run build

CMD ["npm", "run", "serve", "-p", "4000", "-a", "0.0.0.0"]