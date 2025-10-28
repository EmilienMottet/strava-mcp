# HTTP/SSE Mode Implementation - Summary

## Changes Made

### 1. Package Dependencies
**File:** `package.json`

Added:
- `express` (^4.18.2) - HTTP server framework
- `@types/express` (^4.17.21) - TypeScript definitions

### 2. Server Implementation
**File:** `src/server.ts`

Modified the `startServer()` function to support two modes:

#### HTTP/SSE Mode (for MetaMCP)
- Activated when `USE_HTTP=true`
- Creates Express server on port 3000 (configurable)
- Exposes two endpoints:
  - `GET /health` - Health check endpoint
  - `GET /sse` - Server-Sent Events endpoint for MCP communication

#### Stdio Mode (for local development)
- Default mode when `USE_HTTP` is not set
- Uses standard input/output for MCP communication
- Compatible with traditional MCP clients

### 3. Docker Configuration
**File:** `docker-compose.yml`

Updated:
- Changed image to `ghcr.io/emiliermottet/strava-mcp:latest`
- Added `USE_HTTP=true` environment variable
- Added `PORT=3000` environment variable
- Exposed port 3000
- Added health check using wget

**File:** `Dockerfile`

Already had wget installed for health checks - no changes needed.

### 4. Documentation
**New files created:**

- `METAMCP-SETUP.md` - Complete integration guide
- `test-http-mode.sh` - Automated test script
- Updated `.env.example` - Added HTTP mode configuration

## Testing the Implementation

### Local Build and Test

```bash
# Install dependencies
npm install

# Build the project
npm run build

# Test stdio mode (local)
npm run dev

# Test HTTP mode (local)
USE_HTTP=true PORT=3000 npm start
```

### Docker Build and Test

```bash
# Build the image
docker build -t ghcr.io/emiliermottet/strava-mcp:latest .

# Run in HTTP mode
docker run -p 3000:3000 \
  -e USE_HTTP=true \
  -e PORT=3000 \
  -e STRAVA_CLIENT_ID=your_id \
  -e STRAVA_CLIENT_SECRET=your_secret \
  -e STRAVA_ACCESS_TOKEN=your_token \
  -e STRAVA_REFRESH_TOKEN=your_refresh \
  ghcr.io/emiliermottet/strava-mcp:latest

# Test health endpoint
curl http://localhost:3000/health

# Expected response:
# {"status":"ok","name":"Strava MCP Server","version":"1.0.0","transport":"SSE"}
```

### Docker Compose Test

```bash
# Start services
docker-compose up -d

# Run automated tests
./test-http-mode.sh

# Check logs
docker-compose logs -f strava-mcp

# Stop services
docker-compose down
```

## Integration with MetaMCP

### Step 1: Deploy Strava MCP

```bash
# Build and push to registry
docker build -t ghcr.io/emiliermottet/strava-mcp:latest .
docker push ghcr.io/emiliermottet/strava-mcp:latest

# Start with docker-compose
docker-compose up -d

# Verify
./test-http-mode.sh
```

### Step 2: Configure in MetaMCP UI

Add a new MCP server with these settings:

| Field | Value |
|-------|-------|
| **Name** | Strava MCP |
| **Description** | Strava API integration - activities, segments, routes, and stats |
| **Type** | SSE |
| **Ownership** | Private |
| **URL** | http://strava-mcp-server:3000/sse |
| **Environment Variables** | (leave empty) |

### Step 3: Test

In MetaMCP chat:
```
Show me my recent Strava activities
```

## Architecture

### Before (Stdio Mode)
```
MCP Client (Claude Desktop, etc.)
    ↕ stdin/stdout
Strava MCP Server
    ↕ HTTPS
Strava API
```

### After (HTTP/SSE Mode)
```
MetaMCP Container
    ↕ HTTP/SSE (port 3000)
Strava MCP Server Container
    ↕ HTTPS
Strava API
```

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `STRAVA_CLIENT_ID` | Yes | - | Strava API Client ID |
| `STRAVA_CLIENT_SECRET` | Yes | - | Strava API Client Secret |
| `STRAVA_ACCESS_TOKEN` | Yes | - | Strava OAuth Access Token |
| `STRAVA_REFRESH_TOKEN` | Yes | - | Strava OAuth Refresh Token |
| `USE_HTTP` | No | `false` | Enable HTTP/SSE mode |
| `PORT` | No | `3000` | HTTP server port |
| `ROUTE_EXPORT_PATH` | No | `/app/exports` | Directory for GPX/TCX exports |

## Endpoints

### GET /health
Health check endpoint for container orchestration.

**Response:**
```json
{
  "status": "ok",
  "name": "Strava MCP Server",
  "version": "1.0.0",
  "transport": "SSE"
}
```

### GET /sse
Server-Sent Events endpoint for MCP communication.

Expects SSE client connection from MetaMCP or compatible MCP client.

## Troubleshooting

### Issue: Cannot connect from MetaMCP

**Solution:**
1. Verify both containers are on `metamcp-network`
2. Check container name is `strava-mcp-server`
3. Test: `docker exec metamcp ping strava-mcp-server`

### Issue: Health check failing

**Solution:**
1. Check logs: `docker-compose logs strava-mcp`
2. Verify port 3000 is not in use: `netstat -tlnp | grep 3000`
3. Test locally: `curl http://localhost:3000/health`

### Issue: Strava API authentication errors

**Solution:**
1. Verify tokens in `.env` file
2. Run auth setup: `npm run setup-auth`
3. Check token expiration

## Next Steps

1. **Build and push image:**
   ```bash
   docker build -t ghcr.io/emiliermottet/strava-mcp:latest .
   docker push ghcr.io/emiliermottet/strava-mcp:latest
   ```

2. **Deploy with docker-compose:**
   ```bash
   docker-compose up -d
   ```

3. **Run tests:**
   ```bash
   ./test-http-mode.sh
   ```

4. **Configure in MetaMCP** (see above)

5. **Test the integration:**
   - Ask MetaMCP about your Strava activities
   - Verify responses include your actual data

## Compatibility

- ✅ MetaMCP (HTTP/SSE mode)
- ✅ Claude Desktop (stdio mode)
- ✅ Any MCP-compatible client supporting SSE
- ✅ Any MCP-compatible client supporting stdio

## Security Considerations

- Tokens are stored in `.env` file - keep it secure
- Use private ownership in MetaMCP
- Consider network isolation for production
- Rotate API tokens regularly
- Use HTTPS in production (add reverse proxy)
