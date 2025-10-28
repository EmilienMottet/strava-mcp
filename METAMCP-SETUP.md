# MetaMCP Integration Setup

This guide explains how to integrate Strava MCP Server with MetaMCP using HTTP/SSE transport.

## Prerequisites

1. Docker and Docker Compose installed
2. Strava API credentials (Client ID, Client Secret, Access Token, Refresh Token)
3. MetaMCP running

## Setup Steps

### 1. Configure Environment Variables

Create or update your `.env` file with your Strava credentials:

```env
# Strava API Configuration
STRAVA_CLIENT_ID=your_client_id_here
STRAVA_CLIENT_SECRET=your_client_secret_here
STRAVA_ACCESS_TOKEN=your_access_token_here
STRAVA_REFRESH_TOKEN=your_refresh_token_here
```

### 2. Build and Push Docker Image

```bash
# Build the image
docker build -t ghcr.io/emiliermottet/strava-mcp:latest .

# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u emiliermottet --password-stdin

# Push the image
docker push ghcr.io/emiliermottet/strava-mcp:latest
```

### 3. Deploy with Docker Compose

The provided `docker-compose.yml` is configured for HTTP/SSE mode:

```bash
# Create exports directory
mkdir -p strava-exports

# Start the service
docker-compose up -d

# Check logs
docker-compose logs -f strava-mcp

# Verify health
curl http://localhost:3000/health
```

Expected health check response:
```json
{
  "status": "ok",
  "name": "Strava MCP Server",
  "version": "1.0.0",
  "transport": "SSE"
}
```

### 4. Configure in MetaMCP Interface

Open MetaMCP and add a new server with these settings:

**Name:**
```
Strava MCP
```

**Description:**
```
Strava API integration - activities, segments, routes, and stats
```

**Type:**
```
SSE
```

**Ownership:**
```
Private
```

**URL:**
```
http://strava-mcp-server:3000/sse
```

**Environment Variables:** (Leave empty - already configured via docker-compose)
```
(empty)
```

### 5. Verify Integration

Once configured, test the integration by asking MetaMCP:

```
Show me my recent Strava activities
```

or

```
What's my Strava profile?
```

## Troubleshooting

### Connection Issues

If MetaMCP cannot connect:

1. Verify both containers are on the same network:
   ```bash
   docker network inspect metamcp-network
   ```

2. Check Strava MCP logs:
   ```bash
   docker-compose logs strava-mcp
   ```

3. Test the SSE endpoint manually:
   ```bash
   curl -N http://localhost:3000/sse
   ```

### Health Check Failures

If health checks fail:

```bash
# Check if the server is running
docker ps | grep strava-mcp

# Check server logs
docker logs strava-mcp-server

# Test health endpoint
curl http://localhost:3000/health
```

### Token Refresh Issues

If you get authentication errors:

1. Check your tokens in `.env`
2. Run the setup script to get new tokens:
   ```bash
   npm run setup-auth
   ```

## Network Configuration

The `docker-compose.yml` uses the `metamcp-network` external network. Make sure:

1. The network exists:
   ```bash
   docker network ls | grep metamcp
   ```

2. MetaMCP is on the same network

3. Both containers can communicate:
   ```bash
   docker exec metamcp ping strava-mcp-server
   ```

## Development vs Production

### Development (stdio mode)
For local testing without MetaMCP:
```bash
# Remove USE_HTTP=true from docker-compose.yml
# Or run directly:
npm run dev
```

### Production (HTTP/SSE mode)
With MetaMCP integration:
```yaml
environment:
  - USE_HTTP=true
  - PORT=3000
```

## Architecture

```
MetaMCP Container
    |
    | HTTP/SSE (port 3000)
    |
    v
Strava MCP Server Container
    |
    | HTTPS
    |
    v
Strava API (api.strava.com)
```

## Available Tools

Once connected, you'll have access to these Strava MCP tools:

- **Profile & Stats**: `get-athlete-profile`, `get-athlete-stats`, `get-athlete-zones`
- **Activities**: `get-recent-activities`, `get-all-activities`, `get-activity-details`, `get-activity-streams`, `get-activity-laps`
- **Segments**: `list-starred-segments`, `explore-segments`, `get-segment`, `star-segment`, `get-segment-effort`, `list-segment-efforts`
- **Routes**: `list-athlete-routes`, `get-route`, `export-route-gpx`, `export-route-tcx`
- **Clubs**: `list-athlete-clubs`

## Security Notes

- Keep your `.env` file secure and never commit it to version control
- Rotate your Strava API tokens regularly
- Use private ownership in MetaMCP for personal data
- Consider network isolation for production deployments
