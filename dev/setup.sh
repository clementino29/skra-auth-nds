#!/usr/bin/env bash
# Configure une instance authentik de test (dev/docker-compose.yml) comme dans
# les maquettes, puis applique le thème. Usage : ./dev/setup.sh
set -euo pipefail
cd "$(dirname "$0")"
A="http://localhost:9000/api/v3"
H=(-H "Authorization: Bearer dev-token-change-me" -H "Content-Type: application/json")
j() { curl -sf "${H[@]}" "$@"; }
pk() { python3 -c 'import sys,json;print(json.load(sys.stdin)["results"][0]["pk"])'; }

echo "Attente de l'API et des blueprints par défaut…"
until j "$A/stages/identification/?name=default-authentication-identification" | grep -q '"pk"'; do sleep 3; done

# Logo de la brand (copié dans l'image pour le test uniquement)
docker compose cp ../assets/logo-sakura.png server:/web/dist/assets/sakura.png

j -X PATCH "$A/flows/instances/default-authentication-flow/" -d '{"title":"Bienvenue sur le portail Sakura !"}' >/dev/null
j "$A/flows/instances/?slug=recovery" | grep -q '"pk"' || \
  j -X POST "$A/flows/instances/" -d '{"name":"Récupération","slug":"recovery","title":"Récupération","designation":"recovery"}' >/dev/null
j "$A/sources/oauth/?slug=service-lie" | grep -q '"pk"' || \
  j -X POST "$A/sources/oauth/" -d '{"name":"Service lié","slug":"service-lie","provider_type":"openidconnect","consumer_key":"x","consumer_secret":"y","authorization_url":"https://auth.service-lie.fr/application/o/authorize/","access_token_url":"https://auth.service-lie.fr/application/o/token/","profile_url":"https://auth.service-lie.fr/application/o/userinfo/","promoted":true}' >/dev/null

SRC=$(j "$A/sources/oauth/?slug=service-lie" | pk)
REC=$(j "$A/flows/instances/?slug=recovery" | pk)
ID=$(j "$A/stages/identification/?name=default-authentication-identification" | pk)
j -X PATCH "$A/stages/identification/$ID/" -d "{\"password_stage\":null,\"sources\":[\"$SRC\"],\"recovery_flow\":\"$REC\"}" >/dev/null

./apply-css.sh
echo "Prêt : http://localhost:9000/if/flow/default-authentication-flow/ (akadmin / akadmin-dev)"
