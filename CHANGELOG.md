# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
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
- Updated .gitignore to exclude Docker volumes

### Security
- Docker image runs as non-root user
- Optimized Docker image with minimal dependencies

## [1.0.1] - Previous Release

See README.md for previous changes.
