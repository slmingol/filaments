# Filaments - Copilot Agent Instructions

## Project Overview

**Filaments** is a re-implementation of the NYT Strands word puzzle game with multiplayer support. The server is written in Go and serves a TypeScript/Tailwind CSS frontend. Board files are sourced from NYT and cached server-side.

- **Type**: Web game with multiplayer server
- **Languages**: Go 1.22 (server), TypeScript + Tailwind CSS (frontend)
- **Build Tools**: esbuild (TypeScript bundling), tailwindcss CLI, Make
- **Runtime**: Docker (nginx + Go server)
- **Package Manager**: npm (frontend tooling only)

## Project Layout

```
/
├── filaments/                  # Go server package
├── ts/                         # TypeScript frontend source
├── css/                        # CSS source files
├── static/                     # Static assets (fonts, icons)
├── images/                     # Screenshots and assets
├── scripts/
│   └── dark-variant.sh         # Generates dark theme CSS variant
├── out/                        # Build output (gitignored)
├── tempts/                     # Temp TypeScript files during build (gitignored)
├── serv.go                     # Go server entry point
├── go.mod                      # Go module (github.com/hrfee/filaments)
├── go.sum
├── index.html                  # SPA entry
├── base.css                    # Base CSS
├── tailwind.config.js          # Tailwind config
├── inject.js                   # Client-side injection script
├── boards.json                 # Board data cache
├── Dockerfile                  # Production multi-stage build
├── docker-compose.yml          # Full deployment
├── docker-compose.simple.yml   # Simplified deployment
├── nginx.conf                  # nginx config
├── Makefile                    # Build targets
└── DOCKER.md                   # Docker deployment docs
```

## Build & Development Commands (Validated)

### Prerequisites
```bash
npm install     # Install frontend tooling (esbuild, tailwindcss)
go mod download # Download Go dependencies
```

### Frontend Build (from Makefile `debug` target)
```bash
make debug      # Full frontend build → out/
# This runs:
# 1. node scripts/missing-colors.js (inlines colors)
# 2. dark-variant.sh (generates dark theme)
# 3. npx esbuild (bundles TypeScript)
# 4. npx tailwindcss (processes CSS)
# 5. copies static assets to out/
```

### Go Server
```bash
go build -o filaments .     # Build server binary
go test ./...                # Run tests
```

### Docker
```bash
podman compose build
podman compose up
podman compose -f docker-compose.simple.yml up
```

### Environment Variable
```bash
WS_ADDRESS=ws://your-server:8802 make debug   # Override WebSocket address
```

## CI/CD Workflows (`.github/workflows/`)

- **docker-build.yml**: Builds and publishes Docker image on push to main

## Key Architecture Notes
- Frontend is bundled with esbuild (not Webpack/Vite) — keep this in mind when modifying build
- `dark-variant.sh` generates a separate dark-mode CSS variant from the main theme
- `WS_ADDRESS` in Makefile defaults to `ws://0.0.0.0:8802` for local dev; override per-environment
- Go server handles board caching, multiplayer rooms, and static file serving
- `out/` directory is the built frontend — Docker build copies from here

## Common Pitfalls
- Must run `npm install` before `make debug` (esbuild and tailwindcss are npm dependencies)
- `out/` is gitignored — frontend must be rebuilt before Docker build
- `tempts/` is a temporary directory created during build — safe to delete
- WebSocket address (`WS_ADDRESS`) is baked into the JS bundle at build time, not runtime
- `package.json` has only a `test` script — all build commands go through `make`

## Trust these instructions first. Only search if information here is incomplete.
