FROM node:21-alpine AS build

WORKDIR /app
COPY package.json ./
COPY package-lock.json ./

RUN npm install
COPY . ./
RUN npm run build

FROM node:21-alpine

WORKDIR /app
COPY --from=build /app/dist /app/build

# serve 설치 (정적 파일 제공용)
RUN npm install -g serve

EXPOSE 3000
CMD ["serve", "-s", "build"]