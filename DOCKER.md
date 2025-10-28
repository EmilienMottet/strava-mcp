# Docker Deployment Guide

## Quick Start

### Using Docker Compose

1. **Pull the image from GitHub Container Registry:**
   ```bash
   docker pull ghcr.io/r-huijts/strava-mcp:latest
   ```

2. **Create a `.env` file** with your Strava credentials:
   ```bash
   cp .env.example .env
   # Edit .env and add your credentials
   ```

3. **Run with Docker Compose:**
   ```bash
   docker-compose up -d
   ```

### Using Docker directly

```bash
docker run -d \
  --name strava-mcp-server \
  -e STRAVA_CLIENT_ID=your_client_id \
  -e STRAVA_CLIENT_SECRET=your_client_secret \
  -e STRAVA_ACCESS_TOKEN=your_access_token \
  -e STRAVA_REFRESH_TOKEN=your_refresh_token \
  -v $(pwd)/strava-exports:/app/exports \
  -v $(pwd)/.env:/app/.env \
  ghcr.io/r-huijts/strava-mcp:latest
```

## Building Locally

To build the Docker image locally:

```bash
docker build -t strava-mcp:local .
```

## Using with metaMCP

To use this server with metaMCP in a Docker Compose setup:

1. **Create a shared network** (if not already exists):
   ```bash
   docker network create metamcp-network
   ```

2. **Update your metaMCP configuration** to include the Strava MCP server:
   ```json
   {
     "mcpServers": {
       "strava": {
         "command": "docker",
         "args": [
           "exec",
           "-i",
           "strava-mcp-server",
           "node",
           "/app/dist/server.js"
         ]
       }
     }
   }
   ```

3. **Start both services:**
   ```bash
   docker-compose up -d
   ```

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `STRAVA_CLIENT_ID` | Your Strava Application Client ID | Yes |
| `STRAVA_CLIENT_SECRET` | Your Strava Application Client Secret | Yes |
| `STRAVA_ACCESS_TOKEN` | Your Strava API access token | Yes |
| `STRAVA_REFRESH_TOKEN` | Your Strava API refresh token | Yes |
| `ROUTE_EXPORT_PATH` | Path for saving exported route files | No |

## Volumes

- `/app/exports` - Directory for exported GPX/TCX files
- `/app/.env` - Environment file for persistent token storage

## Updating

To update to the latest version:

```bash
docker-compose pull
docker-compose up -d
```

## Troubleshooting

### Check logs
```bash
docker logs strava-mcp-server
```

### Access container shell
```bash
docker exec -it strava-mcp-server sh
```

### Verify environment variables
```bash
docker exec strava-mcp-server env | grep STRAVA
```

## CI/CD

This project includes a GitHub Actions workflow that automatically:
- Builds the Docker image on every push to `main`
- Pushes the image to GitHub Container Registry (ghcr.io)
- Creates version tags based on git tags
- Supports multi-architecture builds (amd64 and arm64)

### Available Tags

- `latest` - Latest build from main branch
- `main` - Alias for latest
- `v*` - Semantic version tags (e.g., `v1.0.0`)
- `sha-<commit>` - Specific commit builds

## Security

The Docker image:
- Runs as a non-root user
- Uses multi-stage builds to minimize size
- Only includes production dependencies
- Supports secrets management through environment variables
