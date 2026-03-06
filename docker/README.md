# Docker Configuration

This directory contains all Docker-related files for the Filaments project.

## Files

- **Dockerfile** - Multi-stage build for frontend (Node.js) and backend (Go)
- **docker-compose.yml** - Full stack with local build
- **docker-compose.simple.yml** - Uses pre-built images from GHCR
- **nginx.conf** - Nginx configuration for serving static files
- **DOCKER.md** - Detailed Docker documentation

## Quick Start

### Using Pre-built Images (Recommended)

```bash
# From project root or docker/ directory
docker-compose -f docker/docker-compose.simple.yml up -d
```

Access the game at http://localhost:8080

### Building Locally

```bash
# From project root or docker/ directory
docker-compose -f docker/docker-compose.yml up -d
```

### Building with Custom WebSocket Address

```bash
# Build with production WebSocket address
docker build -f docker/Dockerfile \
  --build-arg WS_ADDRESS=wss://filaments.example.com/socket \
  -t filaments .
```

## Services

- **filaments-server** - Go WebSocket server on port 8802
- **nginx** - Static file server on port 8080/8081
- **static-init** - One-time container to copy frontend assets

## Volumes

- `boards.json` - Cached NYT board data (persisted)
- `nginx-static` - Frontend assets volume

See [DOCKER.md](DOCKER.md) for detailed documentation.
