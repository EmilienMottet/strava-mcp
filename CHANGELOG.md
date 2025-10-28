# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- **HTTP/SSE Transport Mode**: Support for Server-Sent Events (SSE) for MetaMCP integration
- Express.js HTTP server for containerized deployments
- Health check endpoint (`/health`) for container orchestration
- SSE endpoint (`/sse`) for MCP communication
- `USE_HTTP` environment variable to toggle between stdio and HTTP mode
- Automated test script (`test-http-mode.sh`) for HTTP mode validation
- Comprehensive MetaMCP integration guide (METAMCP-SETUP.md)
- HTTP/SSE implementation documentation (HTTP-SSE-IMPLEMENTATION.md)
- Docker support with multi-stage build
- GitHub Actions CI/CD pipeline for automatic image builds
- Docker Compose configuration for easy deployment
- Support for GitHub Container Registry (ghcr.io)
- Multi-architecture builds (amd64, arm64)
- metaMCP integration documentation
- Docker deployment guide (DOCKER.md)
- metaMCP configuration guide (METAMCP.md)
- Test script for local Docker builds

### Changed
- Updated `src/server.ts` to support both stdio and HTTP/SSE transports
- Modified `.env.example` to include HTTP mode configuration
- Updated `docker-compose.yml` to enable HTTP mode by default
- Updated `package.json` to include Express.js dependencies
- Updated .gitignore to exclude Docker volumes

### Security
- Docker image runs as non-root user
- Optimized Docker image with minimal dependencies

## [1.0.1] - Previous Release

See README.md for previous changes.
