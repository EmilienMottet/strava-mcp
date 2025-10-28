# metaMCP Configuration Example for Strava MCP Server

This guide shows how to integrate the Strava MCP server with metaMCP using Docker.

## Configuration for metaMCP

Add this configuration to your metaMCP setup:

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
      ],
      "env": {
        "STRAVA_CLIENT_ID": "your_client_id",
        "STRAVA_CLIENT_SECRET": "your_client_secret",
        "STRAVA_ACCESS_TOKEN": "your_access_token",
        "STRAVA_REFRESH_TOKEN": "your_refresh_token"
      }
    }
  }
}
```

## Docker Compose Setup with metaMCP

Create a shared network for metaMCP and Strava MCP:

```yaml
version: '3.8'

services:
  strava-mcp:
    image: ghcr.io/r-huijts/strava-mcp:latest
    container_name: strava-mcp-server
    restart: unless-stopped
    env_file:
      - .env
    volumes:
      - ./strava-exports:/app/exports
      - ./.env:/app/.env
    networks:
      - metamcp-network
    stdin_open: true
    tty: true

  # Your metaMCP service here
  # metamcp:
  #   image: your-metamcp-image
  #   networks:
  #     - metamcp-network
  #   ...

networks:
  metamcp-network:
    driver: bridge
```

## Environment Variables

Make sure your `.env` file contains:

```env
STRAVA_CLIENT_ID=your_client_id_here
STRAVA_CLIENT_SECRET=your_client_secret_here
STRAVA_ACCESS_TOKEN=your_access_token_here
STRAVA_REFRESH_TOKEN=your_refresh_token_here
ROUTE_EXPORT_PATH=/app/exports
```

## Starting the Services

```bash
# Start both services
docker-compose up -d

# Check logs
docker-compose logs -f strava-mcp

# Restart if needed
docker-compose restart strava-mcp
```

## Troubleshooting

### Container not starting
```bash
# Check container status
docker ps -a | grep strava-mcp

# View detailed logs
docker logs strava-mcp-server

# Check environment variables
docker exec strava-mcp-server env | grep STRAVA
```

### metaMCP can't connect
1. Ensure both containers are on the same network
2. Verify the container name matches in your metaMCP config
3. Check that stdin_open and tty are set to true
4. Restart both services after configuration changes

### Token expiration
The server automatically refreshes tokens. If you see authentication errors:
1. Check that `STRAVA_REFRESH_TOKEN` is set correctly
2. Ensure the `.env` file is mounted and writable
3. Check logs for token refresh errors
