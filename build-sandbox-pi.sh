#!/usr/bin/env bash
set -euo pipefail

TAG="${1:-pi-sandbox:latest}"

# Resolve host paths
HOME_DIR="${HOME:-$USERPROFILE}"
MODELS_SRC="$HOME_DIR/.pi/agent/models.json"
AUTH_SRC="$HOME_DIR/.pi/agent/auth.json"

# Validate source files exist
for f in "$MODELS_SRC" "$AUTH_SRC"; do
  if [[ ! -f "$f" ]]; then
    echo "ERROR: $f not found" >&2
    exit 1
  fi
done

# Encode file contents as base64
MODELS_B64=$(base64 -w0 "$MODELS_SRC" 2>/dev/null || true)
AUTH_B64=$(base64 -w0 "$AUTH_SRC" 2>/dev/null || true)

echo "Building $TAG ..."
echo "  models.json -> $MODELS_SRC"
echo "  auth.json   -> $AUTH_SRC"

# Pass file contents as base64 build args (no host-side copies needed)
docker build \
  --build-arg MODELS_JSON_B64="$MODELS_B64" \
  --build-arg AUTH_JSON_B64="$AUTH_B64" \
  -t "$TAG" .

echo "Done: $TAG"
