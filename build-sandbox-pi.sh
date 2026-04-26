#!/usr/bin/env bash
set -euo pipefail

TAG="${1:-pi-sandbox:latest}"

# Resolve host paths
HOME_DIR="${HOME:-$USERPROFILE}"
MODELS_SRC="$HOME_DIR/.pi/agent/models.json"
AUTH_SRC="$HOME_DIR/.pi/agent/auth.json"

if [[ -f "$MODELS_SRC" ]]; then
  MODELS_B64=$(base64 -w0 "$MODELS_SRC")
else
  MODELS_B64=$(printf '%s' '{ "providers": {} }' | base64 -w0)
fi

if [[ -f "$AUTH_SRC" ]]; then
  AUTH_B64=$(base64 -w0 "$AUTH_SRC")
else
  AUTH_B64=$(printf '%s' '{}' | base64 -w0)
fi

echo "Building $TAG ..."
echo "  models.json -> $MODELS_SRC"
echo "  auth.json   -> $AUTH_SRC"

# Pass file contents as base64 build args (no host-side copies needed)
docker build \
  --build-arg MODELS_JSON_B64="$MODELS_B64" \
  --build-arg AUTH_JSON_B64="$AUTH_B64" \
  -t "$TAG" .

echo "Done: $TAG"
