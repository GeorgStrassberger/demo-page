# ---- Build-Stage: nur zum Ziehen von Bootstrap
FROM node:20-alpine AS build

WORKDIR /app

COPY package*.json ./

RUN npm ci

# Kopiere restliche Projektdateien (inkl. index.html etc.)
COPY . .

# ---- Runtime-Image ----
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# statische Dateien + node_modules ins nginx-html kopieren
COPY --from=build /app/ ./
