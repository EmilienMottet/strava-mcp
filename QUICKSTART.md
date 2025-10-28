# 🚀 Quick Start Guide - Docker Deployment

Ce guide vous aide à déployer rapidement le serveur Strava MCP avec Docker et GitHub Container Registry.

## 📋 Ce qui a été mis en place

### Fichiers créés :
- ✅ `Dockerfile` - Image Docker optimisée multi-stage
- ✅ `.dockerignore` - Exclusions pour le build Docker
- ✅ `docker-compose.yml` - Configuration Docker Compose
- ✅ `.github/workflows/docker-build-push.yml` - Pipeline CI/CD
- ✅ `DOCKER.md` - Documentation Docker complète
- ✅ `METAMCP.md` - Guide d'intégration metaMCP
- ✅ `scripts/test-docker.sh` - Script de test local
- ✅ `.github/ACTIONS.md` - Documentation GitHub Actions

## 🎯 Utilisation rapide

### Option 1 : Utiliser l'image depuis GitHub Container Registry

```bash
# 1. Pull l'image
docker pull ghcr.io/r-huijts/strava-mcp:latest

# 2. Créer un fichier .env avec vos credentials Strava
cp .env.example .env
# Éditez .env avec vos credentials

# 3. Lancer avec docker-compose
docker-compose up -d

# 4. Vérifier les logs
docker-compose logs -f strava-mcp
```

### Option 2 : Build local pour tester

```bash
# Utiliser le script de test
./scripts/test-docker.sh

# Ou build manuel
docker build -t strava-mcp:test .
docker run -it --rm --env-file .env strava-mcp:test
```

## 🔧 Configuration pour metaMCP

### 1. Réseau Docker partagé

```bash
# Créer le réseau (si nécessaire)
docker network create metamcp-network
```

### 2. Configuration metaMCP

Ajoutez dans votre configuration metaMCP :

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

Voir `METAMCP.md` pour plus de détails.

## 🚀 Déploiement automatique (CI/CD)

### Le workflow GitHub Actions s'exécute automatiquement :

1. **À chaque push sur `main`** → Build et push de l'image `latest`
2. **À chaque tag `v*`** → Build et push avec versions sémantiques
3. **À chaque Pull Request** → Build pour validation (sans push)

### Créer une nouvelle version :

```bash
# Créer et pousser un tag
git tag v1.0.2
git push origin v1.0.2
```

Cela créera automatiquement les tags :
- `ghcr.io/r-huijts/strava-mcp:v1.0.2`
- `ghcr.io/r-huijts/strava-mcp:v1.0`
- `ghcr.io/r-huijts/strava-mcp:v1`
- `ghcr.io/r-huijts/strava-mcp:latest`

## 📦 Rendre le package public

Après le premier build :

1. Aller sur GitHub → Repository → Packages
2. Cliquer sur `strava-mcp`
3. Package settings → Change visibility → Public

## 🔍 Vérification

### Vérifier le build local :
```bash
docker images | grep strava-mcp
```

### Vérifier le workflow GitHub Actions :
1. Aller dans l'onglet "Actions" de votre repo GitHub
2. Vérifier que le workflow "Build and Push Docker Image" s'est exécuté avec succès

### Tester l'image depuis la registry :
```bash
docker pull ghcr.io/r-huijts/strava-mcp:latest
docker run --rm ghcr.io/r-huijts/strava-mcp:latest node --version
```

## 📚 Documentation complète

- **Docker** : Voir `DOCKER.md`
- **metaMCP** : Voir `METAMCP.md`
- **GitHub Actions** : Voir `.github/ACTIONS.md`
- **Changelog** : Voir `CHANGELOG.md`

## ⚙️ Variables d'environnement requises

```env
STRAVA_CLIENT_ID=your_client_id
STRAVA_CLIENT_SECRET=your_client_secret
STRAVA_ACCESS_TOKEN=your_access_token
STRAVA_REFRESH_TOKEN=your_refresh_token
ROUTE_EXPORT_PATH=/app/exports  # optionnel
```

## 🎉 Prochaines étapes

1. **Push vers GitHub** pour déclencher le premier build :
   ```bash
   git add .
   git commit -m "feat: Add Docker support and CI/CD pipeline"
   git push origin main
   ```

2. **Attendre le build** (vérifier dans Actions tab)

3. **Rendre le package public** (voir ci-dessus)

4. **Utiliser dans metaMCP** avec la configuration fournie

## 🆘 Support

En cas de problème :
- Vérifier les logs : `docker-compose logs -f`
- Voir le troubleshooting dans `DOCKER.md`
- Vérifier les permissions GitHub Actions dans `.github/ACTIONS.md`

---

**Prêt à déployer ! 🚀**
