FROM node:20-alpine

WORKDIR /app

COPY ./package.json ./package.json
COPY ./server.js ./server.js
RUN npm install

EXPOSE 5001

CMD ["node", "server.js"]
