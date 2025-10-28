#!/bin/bash

# Script to test the Strava MCP Docker image locally
# This script builds and runs the Docker image for testing purposes

set -e

echo "🐳 Building Strava MCP Docker image..."
docker build -t strava-mcp:test .

echo ""
echo "✅ Build successful!"
echo ""
echo "📋 Available commands:"
echo ""
echo "  1. Run with docker-compose:"
echo "     docker-compose up"
echo ""
echo "  2. Run directly:"
echo "     docker run -it --rm --env-file .env -v \$(pwd)/strava-exports:/app/exports strava-mcp:test"
echo ""
echo "  3. Test the build:"
echo "     docker run -it --rm strava-mcp:test node --version"
echo ""
echo "  4. Inspect the image:"
echo "     docker run -it --rm --entrypoint sh strava-mcp:test"
echo ""
echo "💡 Tip: Make sure your .env file is configured with Strava credentials before running."
