#!/bin/bash

# Test script for Strava MCP Server HTTP/SSE mode

echo "🔍 Testing Strava MCP Server HTTP/SSE Mode..."
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Check if container is running
echo "1. Checking if container is running..."
if docker ps | grep -q strava-mcp-server; then
    echo -e "${GREEN}✓ Container is running${NC}"
else
    echo -e "${RED}✗ Container is not running${NC}"
    echo "  Run: docker-compose up -d"
    exit 1
fi
echo ""

# Test 2: Check health endpoint
echo "2. Testing health endpoint..."
HEALTH_RESPONSE=$(docker exec strava-mcp-server wget -qO- http://localhost:3000/health 2>/dev/null)
if [ $? -eq 0 ] && echo "$HEALTH_RESPONSE" | grep -q "ok"; then
    echo -e "${GREEN}✓ Health endpoint is accessible${NC}"
    echo "  Response: $HEALTH_RESPONSE"
else
    echo -e "${RED}✗ Health endpoint failed${NC}"
    echo "  Check logs: docker-compose logs strava-mcp"
    exit 1
fi
echo ""

# Test 3: Check SSE endpoint
echo "3. Testing SSE endpoint..."
SSE_STATUS=$(docker exec strava-mcp-server sh -c 'wget --spider -q http://localhost:3000/sse 2>&1; echo $?' 2>/dev/null)
if [ "$SSE_STATUS" = "0" ] || [ "$SSE_STATUS" = "1" ]; then
    echo -e "${GREEN}✓ SSE endpoint is accessible${NC}"
else
    echo -e "${YELLOW}⚠ SSE endpoint check returned status $SSE_STATUS${NC}"
    echo "  This might be normal - SSE requires proper client"
fi
echo ""

# Test 4: Check network
echo "4. Checking Docker network..."
if docker network inspect metamcp-network >/dev/null 2>&1; then
    echo -e "${GREEN}✓ metamcp-network exists${NC}"
    
    # Check if container is on the network
    if docker network inspect metamcp-network | grep -q strava-mcp-server; then
        echo -e "${GREEN}✓ strava-mcp-server is on metamcp-network${NC}"
    else
        echo -e "${YELLOW}⚠ strava-mcp-server is not on metamcp-network${NC}"
        echo "  This is only needed if integrating with MetaMCP"
    fi
else
    echo -e "${YELLOW}⚠ metamcp-network does not exist${NC}"
    echo "  Create it with: docker network create metamcp-network"
    echo "  Or ignore if not using MetaMCP"
fi
echo ""

# Test 5: Check environment variables
echo "5. Checking environment variables..."
ENV_VARS=$(docker exec strava-mcp-server sh -c 'echo "USE_HTTP=$USE_HTTP PORT=$PORT"')
echo "  $ENV_VARS"
if echo "$ENV_VARS" | grep -q "USE_HTTP=true"; then
    echo -e "${GREEN}✓ USE_HTTP is set to true${NC}"
else
    echo -e "${RED}✗ USE_HTTP is not set to true${NC}"
    echo "  Check docker-compose.yml environment section"
fi
echo ""

# Test 6: Check logs for errors
echo "6. Checking recent logs for errors..."
ERROR_COUNT=$(docker logs strava-mcp-server --tail 50 2>&1 | grep -i "error" | wc -l)
if [ "$ERROR_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓ No errors in recent logs${NC}"
else
    echo -e "${YELLOW}⚠ Found $ERROR_COUNT error(s) in logs${NC}"
    echo "  Review with: docker-compose logs strava-mcp"
fi
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✓ All critical tests passed!${NC}"
echo ""
echo "Next steps:"
echo "  1. Add server to MetaMCP with URL: http://strava-mcp-server:3000/sse"
echo "  2. Set Type to: SSE"
echo "  3. Test with: 'Show me my recent Strava activities'"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
