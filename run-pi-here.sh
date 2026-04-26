#!/usr/bin/env bash
set -euo pipefail
export MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL="*"

PROJECT_DIR="${1:-.}"

# Resolve absolute project path
ABS_PROJECT="$(pwd)/$PROJECT_DIR"

echo "Running pi-sandbox:latest with >$ABS_PROJECT< mounted to /root/workspace ..."

docker run -it --rm -v ${ABS_PROJECT}:/root/workspace:rw -e PI_PROJECT_DIR=/root/workspace -w /root/workspace   pi-sandbox:latest
