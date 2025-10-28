# Configuration MetaMCP avec StreamableHTTP

## Problème résolu

L'ancienne configuration utilisait le transport SSE (deprecated) qui causait des erreurs 404 :
```
Cannot POST /sse
```

Le nouveau transport **StreamableHTTP** est maintenant implémenté.

## Configuration MetaMCP

### Option 1 : URL directe dans MetaMCP UI

Dans l'interface MetaMCP, configurez votre serveur Strava avec :

**URL du serveur** :
```
http://strava-mcp-server:3000/message
```

**Type de transport** :
```
StreamableHTTP
```

### Option 2 : Fichier de configuration

Utilisez le fichier `server-http.json` fourni :

```json
{
  "name": "io.github.r-huijts/strava-mcp",
  "packages": [
    {
      "identifier": "strava-mcp-server",
      "transport": {
        "type": "streamable-http",
        "url": "http://strava-mcp-server:3000/message"
      }
    }
  ]
}
```

## Redémarrage nécessaire

Après avoir modifié le code :

```bash
# Rebuild et redémarrer le conteneur
docker compose down
docker compose build strava-mcp-server
docker compose up -d

# Vérifier que le serveur démarre correctement
docker compose logs strava-mcp-server -f
```

## Vérification

### 1. Health check
```bash
curl http://localhost:3000/health
```

Devrait retourner :
```json
{
  "status": "ok",
  "name": "Strava MCP Server",
  "version": "1.0.0",
  "transport": "StreamableHTTP"
}
```

### 2. Test du endpoint /message
```bash
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc": "2.0", "method": "initialize", "id": 1}'
```

### 3. Ancien endpoint SSE (devrait retourner 404)
```bash
curl http://localhost:3000/sse
```

Devrait retourner :
```json
{
  "error": "SSE transport is deprecated",
  "message": "Please use StreamableHTTP transport at /message endpoint"
}
```

## Dans MetaMCP

Une fois configuré, MetaMCP devrait :
- Se connecter sans erreur 404
- Afficher "Strava MCP Server" dans la liste des serveurs actifs
- Permettre d'utiliser tous les outils Strava

## Dépannage

Si vous voyez encore des erreurs :

1. **Vérifiez les logs du serveur** :
   ```bash
   docker compose logs strava-mcp-server -f
   ```

2. **Vérifiez que USE_HTTP est activé dans .env** :
   ```
   USE_HTTP=true
   ```

3. **Vérifiez la connectivité réseau** :
   ```bash
   # Depuis le conteneur MetaMCP
   docker compose exec metamcp curl http://strava-mcp-server:3000/health
   ```

4. **Supprimez et recréez la configuration dans MetaMCP** :
   - Supprimez le serveur Strava existant
   - Ajoutez-le à nouveau avec l'URL `/message`
   - Assurez-vous que le type est "StreamableHTTP"
