# Docker Deployment Guide

This project includes Docker support for easy deployment.

## Quick Start

### Option 1: Build and Run Locally

Build and run the complete stack (game server + nginx):

```bash
docker-compose up -d
```

This will:
- Build the filaments server with frontend assets
- Start nginx to serve static files
- Set up WebSocket proxying for multiplayer functionality

Access the game at: http://localhost:8080

### Option 2: Deploy from Pre-built Image (GHCR)

Use the pre-built image from GitHub Container Registry:

```bash
docker-compose -f docker-compose.simple.yml up -d
```

This pulls the latest image from `ghcr.io/slmingol/filaments:latest` instead of building locally.

## Architecture

The Docker setup consists of:

1. **filaments-server**: Go-based WebSocket server for multiplayer functionality
   - Runs on port 8802
   - Handles game logic and board caching
   
2. **nginx**: Web server for static assets
   - Serves the game UI on port 8080
   - Proxies WebSocket connections to the game server at `/socket`
   
3. **static-init**: Helper container that copies built frontend assets to nginx

## Configuration

### Ports

- **8080**: Main HTTP port for the game UI
- **8802**: WebSocket server port (proxied through nginx at `/socket`)

To change ports, edit the `ports` section in `docker-compose.yml` or `docker-compose.simple.yml`:

```yaml
services:
  nginx:
    ports:
      - "3000:80"  # Access game at http://localhost:3000
```

### WebSocket Address

The WebSocket address is configured during build. To change it:

```bash
docker build --build-arg WS_ADDRESS=ws://your-domain.com/socket -t filaments .
```

### Board Cache

Game boards are cached in `boards.json`. This file is persisted using a volume mount to avoid re-downloading boards.

## CI/CD Pipeline

The repository includes a GitHub Actions workflow (`.github/workflows/docker-build.yml`) that:

1. Builds the Docker image on every push to `main`
2. Pushes the image to GitHub Container Registry (GHCR)
3. Tags images with:
   - `latest` for main branch
   - Commit SHA
   - Branch name
4. Supports multi-platform builds (amd64/arm64)

### Triggering Builds

Images are automatically built when:
- Code is merged to the `main` branch
- Pull requests are opened (build only, no push)

### Using CI-Built Images

After the CI pipeline runs, pull the latest image:

```bash
docker pull ghcr.io/slmingol/filaments:latest
docker-compose -f docker-compose.simple.yml up -d
```

## Development

For development with hot-reload, use the standard development workflow:

```bash
npm install
make debug
./serv 0.0.0.0 8802
```

See the main [README.md](README.md) for more details.

## Troubleshooting

### WebSocket Connection Issues

If multiplayer isn't working:
1. Check that nginx is correctly proxying `/socket` to the game server
2. Verify firewall rules allow WebSocket connections
3. Check nginx logs: `docker logs filaments-nginx`
4. Check server logs: `docker logs filaments-server`

### Static Files Not Loading

If the UI doesn't appear:
1. Ensure the static-init container ran successfully
2. Check nginx logs: `docker logs filaments-nginx`
3. Verify the volume mount: `docker volume inspect filaments_nginx-static`

### Rebuilding After Changes

```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Production Deployment

For production:

1. Use `docker-compose.simple.yml` with pre-built images
2. Configure a reverse proxy (nginx/Caddy) with SSL
3. Update the WebSocket address to use `wss://` (secure WebSocket)
4. Set appropriate timeout values for WebSocket connections (1h recommended)
5. Consider using Docker secrets for sensitive configuration

Example production nginx config included in main [README.md](README.md).
