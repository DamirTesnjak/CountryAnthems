FROM node:20-alpine

WORKDIR /app

COPY ./package.json ./package.json
COPY ./server.js ./server.js
RUN npm install
RUN npm install pg@latest

EXPOSE 5001

CMD ["node", "server.js"]

