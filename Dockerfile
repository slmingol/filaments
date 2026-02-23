# Build frontend assets
FROM node:20-alpine AS frontend

WORKDIR /build

# Install perl (required by build scripts)
RUN apk add --no-cache perl bash

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci

# Copy source files
COPY . .

# Build frontend assets
ENV WS_ADDRESS=ws://localhost:8802
RUN mkdir -p out && \
    NOTEMPLATE=1 node ./scripts/missing-colors.js index.html out/index.html && \
    cp -r node_modules/remixicon/fonts/remixicon.css node_modules/remixicon/fonts/remixicon.woff2 out/ && \
    rm -rf tempts && \
    cp -r ts tempts && \
    ./scripts/dark-variant.sh tempts && \
    sed -i "s!ws://0.0.0.0:8802!${WS_ADDRESS}!g" tempts/main.ts && \
    npx esbuild --bundle base.css --outfile=out/bundle.css --external:remixicon.css --external:../fonts/hanken* --external:../fonts/NeverMind* --minify && \
    npx esbuild --target=es6 --bundle tempts/main.ts --outfile=out/main.js --minify && \
    npx tailwindcss -c tailwind.config.js -i out/bundle.css -o out/bundle.css && \
    cp images/src/*.svg out/ && \
    cp -r ./static/* out/

# Build Go server
FROM golang:1.23-alpine AS backend

WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download

COPY serv.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -o serv serv.go

# Final runtime image
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /app

# Copy the Go server binary
COPY --from=backend /build/serv /app/serv

# Copy the frontend assets
COPY --from=frontend /build/out /app/static

EXPOSE 8802

CMD ["/app/serv", "0.0.0.0", "8802"]


