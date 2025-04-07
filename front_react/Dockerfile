FROM node:21-alpine AS build

WORKDIR /app
COPY package.json ./
COPY package-lock.json ./

RUN npm i
COPY . ./
RUN npm run build

FROM node:21-alpine

WORKDIR /app
COPY --from=build /app/build /app/build

EXPOSE 3000

CMD ["npm", "start"]