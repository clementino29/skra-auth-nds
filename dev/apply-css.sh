#!/usr/bin/env bash
# Pousse ../nohriancons-authentik.css dans le champ Custom CSS de la brand par défaut.
set -euo pipefail
cd "$(dirname "$0")"
python3 - ../nohriancons-authentik.css <<'PY'
import json, sys, urllib.request
api = "http://localhost:9000/api/v3/core/brands/"
hdr = {"Authorization": "Bearer dev-token-change-me", "Content-Type": "application/json"}
brands = json.load(urllib.request.urlopen(urllib.request.Request(api + "?default=true", headers=hdr)))
uuid = brands["results"][0]["brand_uuid"]
body = {"branding_custom_css": open(sys.argv[1]).read(),
        "branding_logo": "/static/dist/assets/sakura.png", "branding_title": "Sakura App"}
req = urllib.request.Request(api + uuid + "/", data=json.dumps(body).encode(), method="PATCH", headers=hdr)
print("CSS appliqué :", urllib.request.urlopen(req).status)
PY
