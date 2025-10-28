#!/bin/bash

# Test script for StreamableHTTP transport

echo "🧪 Testing Strava MCP Server - StreamableHTTP Transport"
echo "=========================================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Server URL
SERVER_URL="http://localhost:3000"

# Test 1: Health Check
echo "📋 Test 1: Health Check"
echo "Endpoint: GET $SERVER_URL/health"
echo ""

HEALTH_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "$SERVER_URL/health")
HTTP_STATUS=$(echo "$HEALTH_RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)
RESPONSE_BODY=$(echo "$HEALTH_RESPONSE" | sed '/HTTP_STATUS/d')

if [ "$HTTP_STATUS" = "200" ]; then
    echo -e "${GREEN}✓ Health check passed${NC}"
    echo "Response: $RESPONSE_BODY"
    
    # Check if transport is StreamableHTTP
    if echo "$RESPONSE_BODY" | grep -q "StreamableHTTP"; then
        echo -e "${GREEN}✓ Transport is correctly set to StreamableHTTP${NC}"
    else
        echo -e "${YELLOW}⚠ Transport is not StreamableHTTP${NC}"
    fi
else
    echo -e "${RED}✗ Health check failed (HTTP $HTTP_STATUS)${NC}"
    echo "Response: $RESPONSE_BODY"
fi

echo ""
echo "----------------------------------------"
echo ""

# Test 2: StreamableHTTP Message Endpoint
echo "📋 Test 2: StreamableHTTP Message Endpoint"
echo "Endpoint: POST $SERVER_URL/message"
echo ""

MESSAGE_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
    -X POST "$SERVER_URL/message" \
    -H "Content-Type: application/json" \
    -d '{
        "jsonrpc": "2.0",
        "method": "initialize",
        "id": 1,
        "params": {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {
                "name": "test-client",
                "version": "1.0.0"
            }
        }
    }')

HTTP_STATUS=$(echo "$MESSAGE_RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)
RESPONSE_BODY=$(echo "$MESSAGE_RESPONSE" | sed '/HTTP_STATUS/d')

if [ "$HTTP_STATUS" = "200" ]; then
    echo -e "${GREEN}✓ Message endpoint responding${NC}"
    echo "Response: $RESPONSE_BODY"
else
    echo -e "${RED}✗ Message endpoint failed (HTTP $HTTP_STATUS)${NC}"
    echo "Response: $RESPONSE_BODY"
fi

echo ""
echo "----------------------------------------"
echo ""

# Test 3: Legacy SSE Endpoint (should return 404 or error)
echo "📋 Test 3: Legacy SSE Endpoint (should be deprecated)"
echo "Endpoint: GET $SERVER_URL/sse"
echo ""

SSE_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "$SERVER_URL/sse")
HTTP_STATUS=$(echo "$SSE_RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)
RESPONSE_BODY=$(echo "$SSE_RESPONSE" | sed '/HTTP_STATUS/d')

if [ "$HTTP_STATUS" = "404" ]; then
    echo -e "${GREEN}✓ SSE endpoint correctly returns 404 (deprecated)${NC}"
    echo "Response: $RESPONSE_BODY"
elif echo "$RESPONSE_BODY" | grep -q "deprecated"; then
    echo -e "${GREEN}✓ SSE endpoint returns deprecation message${NC}"
    echo "Response: $RESPONSE_BODY"
else
    echo -e "${YELLOW}⚠ Unexpected response from SSE endpoint (HTTP $HTTP_STATUS)${NC}"
    echo "Response: $RESPONSE_BODY"
fi

echo ""
echo "=========================================================="
echo "🏁 Test Complete"
echo ""

# Summary
echo "Summary:"
echo "--------"
echo "If all tests passed, your server is correctly configured for StreamableHTTP."
echo "You can now configure MetaMCP with:"
echo "  URL: http://strava-mcp-server:3000/message"
echo "  Transport: StreamableHTTP"
