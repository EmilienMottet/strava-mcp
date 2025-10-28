# GitHub Actions Configuration

## Automatic Setup

The CI/CD pipeline is configured to work automatically with GitHub's built-in features:

- **Authentication**: Uses `GITHUB_TOKEN` (automatically provided by GitHub Actions)
- **Registry**: Pushes to GitHub Container Registry (ghcr.io)
- **Permissions**: Configured in the workflow file

## First Time Setup

### 1. Enable GitHub Container Registry

The workflow will automatically push to `ghcr.io/r-huijts/strava-mcp`. No additional configuration is needed.

### 2. Make the Package Public (Optional)

After the first successful build:

1. Go to your repository on GitHub
2. Navigate to "Packages" in the right sidebar
3. Click on the `strava-mcp` package
4. Go to "Package settings"
5. Under "Danger Zone", click "Change visibility"
6. Select "Public" to allow anyone to pull the image

### 3. Verify the Workflow

The workflow will trigger automatically on:
- Push to `main` branch
- Creation of version tags (e.g., `v1.0.0`)
- Pull requests to `main`
- Manual trigger via "Actions" tab

## Workflow Features

### Multi-Architecture Support
The workflow builds images for:
- `linux/amd64` (x86_64)
- `linux/arm64` (ARM64/Apple Silicon)

### Automatic Tagging
The workflow creates multiple tags:
- `latest` - Latest build from main branch
- `main` - Alias for latest
- `v1.0.0` - Semantic version (if you push a git tag)
- `sha-abc123` - Specific commit builds

### Caching
Uses GitHub Actions cache to speed up builds:
- Layer caching between builds
- Dependency caching

## Creating a Release

To create a new version:

```bash
# Tag the release
git tag v1.0.2
git push origin v1.0.2

# Or create through GitHub UI
# Releases > Draft a new release > Choose a tag > Create tag
```

This will trigger a build with version tags:
- `ghcr.io/r-huijts/strava-mcp:v1.0.2`
- `ghcr.io/r-huijts/strava-mcp:v1.0`
- `ghcr.io/r-huijts/strava-mcp:v1`
- `ghcr.io/r-huijts/strava-mcp:latest`

## Monitoring Builds

### View Build Status
1. Go to the "Actions" tab in your repository
2. Click on the latest workflow run
3. View build logs and status

### Download Build Artifacts
Build provenance attestations are automatically generated for security and traceability.

## Troubleshooting

### Permission Denied
If you see permission errors:
1. Go to repository Settings > Actions > General
2. Under "Workflow permissions", ensure "Read and write permissions" is selected
3. Save and re-run the workflow

### Package Not Found
If you can't pull the image:
1. Verify the package visibility (public vs private)
2. For private packages, authenticate with:
   ```bash
   echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
   ```

### Build Failures
Check the workflow logs for specific errors:
1. Go to Actions tab
2. Click on the failed workflow
3. Expand the failed step to see error details

## Local Testing

Before pushing, test the Docker build locally:

```bash
# Run the test script
./scripts/test-docker.sh

# Or build manually
docker build -t strava-mcp:test .
docker run -it --rm --env-file .env strava-mcp:test
```

## Security

The workflow includes:
- Build provenance attestation (SLSA)
- Runs as non-root user in container
- No secrets required (uses GITHUB_TOKEN)
- Automated security scanning (can be added via GitHub Advanced Security)

## Custom Registry

To push to a different registry (e.g., Docker Hub):

1. Add registry credentials as repository secrets:
   - `DOCKER_USERNAME`
   - `DOCKER_PASSWORD`

2. Update the workflow file:
   ```yaml
   - name: Log in to Docker Hub
     uses: docker/login-action@v3
     with:
       username: ${{ secrets.DOCKER_USERNAME }}
       password: ${{ secrets.DOCKER_PASSWORD }}
   ```

3. Change `REGISTRY` environment variable to `docker.io`
